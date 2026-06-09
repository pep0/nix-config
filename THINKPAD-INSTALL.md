# ThinkPad NixOS install — vifslan

Self-contained walkthrough. Save this to your phone before you boot
the installer; it's the only reference you'll need from "wipe Ubuntu"
through "TPM auto-unlock working".

Hostname is `vifslan`. Linux user is `pep0`. Disk is `/dev/nvme0n1`
(the P14s Gen 5 only has the M.2 NVMe slot — confirm with `lsblk -d`
if unsure).

End state:

- Full-disk encryption (LUKS2 / argon2id) on root
- 1 GiB unencrypted EFI System Partition
- ext4 on the decrypted volume
- No disk swap (zram if needed later)
- Hyprland + niri login picker via greetd / tuigreet
- Lanzaboote Secure Boot with your own keys
- TPM2 auto-unlocks LUKS at boot once the chain is enrolled

Total time on a healthy fibre connection: 60–90 min including all
post-install steps.

---

## 0. Before you wipe Ubuntu

1. **Back up `/home`** to an external drive or remote. Don't trust
   that you've already got everything elsewhere — copy it again.
   ```
   sudo rsync -aHAX --info=progress2 /home/<user>/ /mnt/external/home-backup/
   ```

2. **Boot into BIOS** (power on → F1 during Lenovo splash) and:
   - Set a **supervisor password** if you don't have one. LUKS + SB
     are pointless if someone can disable Secure Boot in firmware.
   - Note whether Secure Boot is on. Leave it as-is for now; you'll
     reset it to "Setup Mode" later for Lanzaboote.
   - Confirm SATA is **AHCI** (default on modern ThinkPads).

3. **Plug in AC**. The installer will pull and build a lot.

---

## 1. Build the installer USB (do this on Ubuntu before wiping)

1. Download the latest **NixOS 26.05 minimal ISO** from
   https://nixos.org/download (the "minimal" image, not "graphical").
   Filename is roughly `nixos-minimal-26.05-x86_64-linux.iso`.

2. Find your USB device:
   ```
   lsblk -d
   ```
   It'll be the one that matches the size of your stick (something
   like `/dev/sdb`, not `/dev/nvme0n1`).

3. Flash. **Double-check the device** before pressing enter:
   ```
   sudo dd if=~/Downloads/nixos-minimal-26.05-x86_64-linux.iso \
           of=/dev/sdX bs=4M status=progress conv=fsync
   sync
   ```
   Replace `/dev/sdX` with your USB device. Do not pick a partition
   like `/dev/sdX1` — must be the whole device.

---

## 2. Boot from USB on the ThinkPad

1. Plug the USB into the ThinkPad. Power on, press **F12** at the
   Lenovo splash to get the boot menu. Pick the USB.
2. You land in a NixOS live shell as user `nixos`. Prompt looks like
   `[nixos@nixos:~]$`.

---

## 3. Networking inside the installer

ThinkPad Wi-Fi works out of the box in the live ISO.

```
sudo systemctl start NetworkManager
nmtui                                  # arrow-key picker; "Activate a connection"
ping -c 3 1.1.1.1                      # verify
```

If you'd rather use ethernet via a dock or USB adapter, plug it in
and DHCP just works.

---

## 4. Partition the disk with LUKS

Confirm the SSD path:
```
lsblk -d
```
Should show `/dev/nvme0n1` with the size of your SSD.

Wipe and partition (this destroys everything on the disk):
```
sudo wipefs -a /dev/nvme0n1
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 1GiB 100%
```

You should now have:
- `/dev/nvme0n1p1` — 1 GiB EFI partition
- `/dev/nvme0n1p2` — the rest, to be encrypted

Format the ESP:
```
sudo mkfs.fat -F32 -n boot /dev/nvme0n1p1
```

LUKS-encrypt the root partition. You'll be asked for a passphrase
**twice**. Pick a long, memorable one — you'll type it at the
pre-boot prompt every time (until TPM unlock is set up in step 11):
```
sudo cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
```
Defaults to LUKS2 with argon2id (memory-hard KDF; resists GPU attacks).

Open the encrypted device — this maps it to `/dev/mapper/cryptroot`:
```
sudo cryptsetup open /dev/nvme0n1p2 cryptroot
```
Asks for the passphrase you just set.

Format ext4 on the decrypted device:
```
sudo mkfs.ext4 -L nixos /dev/mapper/cryptroot
```

Mount in the installer's expected layout:
```
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

Sanity check:
```
mount | grep nvme
```
You should see `/dev/mapper/cryptroot on /mnt type ext4` and
`/dev/nvme0n1p1 on /mnt/boot type vfat`.

---

## 5. Generate the hardware config

```
sudo nixos-generate-config --root /mnt
```

Verify the LUKS device line was detected:
```
grep -A3 luks /mnt/etc/nixos/hardware-configuration.nix
```

Expected output (UUID will differ):
```
boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/...";
```

If that line is missing, the system won't be able to unlock the disk
at boot. Add it manually before continuing — the UUID is what
`blkid /dev/nvme0n1p2` reports under `UUID=` (LUKS UUID).

---

## 6. Clone the flake and wire in the hardware config

```
nix-shell -p git --run 'git clone https://github.com/pep0/nix-config /mnt/etc/nixos/nix-config'
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nix-config/hosts/vifslan/
```

---

## 7. Install

```
sudo nixos-install --flake /mnt/etc/nixos/nix-config#vifslan
```

This will:
1. Substitute most of the closure from cache.nixos.org plus Hyprland
   and niri cachixes.
2. Build whatever isn't cached.
3. At the very end, prompt for the **root password**. Set something
   you can type at the TTY — this is only used if your user account
   breaks or if a service needs root recovery.

Once it finishes:
```
sudo reboot
```
Pull the USB while it's powering off.

---

## 8. First boot

You'll see:

1. The systemd-boot menu (Lanzaboote isn't enrolled yet).
2. After picking the default entry, a **LUKS passphrase prompt**.
   Enter the passphrase from step 4.
3. The system boots through and lands at the greetd login.

Switch to TTY1 with **Ctrl+Alt+F1** and log in as `root` with the
password from step 7. Set the user password:
```
passwd pep0
```

Type `exit`, then **Ctrl+Alt+F7** (or whichever F-key greetd is on)
to get back to the graphical login. The session picker should show
`Hyprland` and `niri`. Pick one, log in as `pep0`.

You should see kitty (the terminal), waybar at the top, and the
basic compositor working.

---

## 9. Move the flake to its declared home

The flake's `programs.nh.flake` points at `/home/pep0/nix-config`.
Move the install-time clone there so `nh os switch` works without
arguments:
```
sudo mv /etc/nixos/nix-config /home/pep0/nix-config
sudo chown -R pep0:users /home/pep0/nix-config
cd ~/nix-config
make diff               # should evaluate cleanly and show no diff
```

---

## 10. Lanzaboote (Secure Boot with your own keys)

Do this **after** confirming the system boots and you're comfortable
with the LUKS passphrase workflow.

### 10a. Pre-flight

```
sudo bootctl status
```
You want `Firmware: UEFI` and `Current Boot Loader: systemd-boot`.

```
ls /etc/secureboot 2>/dev/null
```
Should be empty / nonexistent — we're about to create keys.

### 10b. Generate Secure Boot keys

```
sudo sbctl create-keys
```
Keys land in `/var/lib/sbctl/`. Treat that directory like LUKS
passphrases — if the laptop dies, you regenerate them on the new
install.

### 10c. Switch BIOS to Setup Mode

Reboot, F1 to enter BIOS:
- Security → Secure Boot → set to **Enabled** (if not already)
- Secure Boot → **Reset to Setup Mode** (or "Erase All Secure Boot
  Settings", "Restore Factory Keys" then clear — wording varies by
  BIOS rev)
- F10 to save and exit

### 10d. Enable Lanzaboote in the flake

Edit `~/nix-config/modules/system/secureboot.nix`:
- Change `boot.lanzaboote.enable = false;` to `true`
- Uncomment `pkiBundle = "/var/lib/sbctl";`
- Uncomment `boot.loader.systemd-boot.enable = lib.mkForce false;`

Rebuild:
```
cd ~/nix-config
make system
sudo reboot
```

### 10e. Enroll your keys

After the reboot (still in Setup Mode, Lanzaboote-signed UEFI
binary loads):
```
sudo sbctl enroll-keys --microsoft
```
The `--microsoft` flag also enrolls Microsoft's third-party keys so
OptionROMs (fingerprint reader firmware, some GPU firmware) keep
loading.

### 10f. Re-enable Secure Boot

Reboot, F1 → Security → Secure Boot → set back to **Enabled** with
your own keys active (no longer Setup Mode). F10 save & exit.

### 10g. Verify

After reboot, log in and run:
```
sudo sbctl status
```
Want:
- `Secure Boot: enabled (user)`
- `Setup Mode: disabled`

```
sudo sbctl verify
```
Every relevant binary should show `signed`.

If something breaks during 10c–10f, boot the NixOS installer USB,
mount your disks (`cryptsetup open /dev/nvme0n1p2 cryptroot; mount
/dev/disk/by-label/nixos /mnt`), edit `secureboot.nix` to flip
enable back off, and `nixos-install --flake /mnt/etc/nixos/nix-config#vifslan`
again. You can also boot via the BIOS boot menu picking the
systemd-boot entry if it's still on the ESP.

---

## 11. TPM2 auto-unlock for LUKS

Only after step 10 succeeds — TPM unlock binds to PCR 7 which
encodes "Secure Boot enabled with these keys". Without SB enrolled,
PCR 7 is meaningless.

### 11a. Verify TPM is present

```
sudo dmesg | grep -i tpm
ls /dev/tpm*
```
You want `/dev/tpm0` and `/dev/tpmrm0`. Should be there on any
P14s Gen 5.

### 11b. Confirm the module is active

Already wired in `hosts/vifslan/default.nix` (imports
`modules/system/tpm-unlock.nix`). After step 7 the initrd already
has systemd + TPM support, so the first reboot in this section will
just confirm fallback works:
```
sudo reboot
```
You'll still get the passphrase prompt — nothing's enrolled yet.
That's the expected fallback behavior. Type the passphrase.

### 11c. Enroll the TPM against PCR 7

```
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```
You'll be asked for an existing LUKS passphrase to authorize
creating the new keyslot. The TPM seals a random key against PCR 7
and stores it in a new LUKS keyslot.

### 11d. Reboot and verify

```
sudo reboot
```

This time, **no passphrase prompt** — initrd queries the TPM, PCR 7
matches, the key drops out, LUKS unlocks, boot proceeds.

```
sudo systemd-cryptenroll /dev/nvme0n1p2
```
Should list at least two slots: one `password` (your original) and
one `tpm2`.

### 11e. When things change

If you ever re-run `sbctl enroll-keys`, do a BIOS update, or
"Restore Factory Keys" in BIOS — PCR 7 changes, TPM refuses to
release the key, and you fall back to the passphrase. To restore
auto-unlock:
```
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```

**Don't** wipe the password slot. If the motherboard or TPM dies,
the password slot is your only way back into the disk.

---

## 12. Verify everything (after step 11)

| Check | Command | Expected |
|---|---|---|
| LUKS root mounted | `mount \| grep cryptroot` | `/dev/mapper/cryptroot on / type ext4` |
| Secure Boot | `sudo sbctl status` | `Secure Boot: enabled (user)` |
| TPM keyslot | `sudo systemd-cryptenroll /dev/nvme0n1p2` | `tpm2` slot listed |
| Wi-Fi | `nmcli device wifi list` | scan results |
| Bluetooth | `bluetoothctl power on && bluetoothctl scan on` | nearby devices |
| NVIDIA dGPU available | `nvidia-smi` | GPU info |
| TLP active | `sudo tlp-stat -b` | charge thresholds 60/80 |
| Both compositors | log out → greetd | session picker shows Hyprland + niri |
| `make diff` evaluates | `cd ~/nix-config && make diff` | no errors, no changes |

---

## Optional follow-ups

- **Tailscale**: run `sudo tailscale up --ssh` once to auth the
  machine to your tailnet.
- **Wallpaper**: the default is a 1×1 base-color stylix image.
  Replace `image = config.lib.stylix.pixel "base00";` in
  `modules/system/stylix.nix` with a real image path.
- **sops-nix secrets**: only needed when you want to store an
  encrypted secret (Wi-Fi PSK, etc.). Skip until then; the bootstrap
  is in `SECRETS.md`.
- **TLP charge thresholds**: currently 60/80. Bump to 75/95 if you
  want to actually use full battery capacity day-to-day (edit
  `modules/system/power.nix`).

---

## Troubleshooting

**Wi-Fi doesn't connect in the installer**
Use a USB-tether from your phone, or plug in a USB-to-Ethernet
adapter.

**`nixos-install` fails partway through**
Note the error, run it again — substituters might have hiccuped.
Persistent failures are usually missing inputs in
`hardware-configuration.nix`.

**LUKS passphrase prompt doesn't appear at boot**
Boot the installer USB, mount the disks, check
`/mnt/etc/nixos/nix-config/hosts/vifslan/hardware-configuration.nix`
has `boot.initrd.luks.devices."cryptroot".device = ...`. Re-run
`nixos-install` if you fix it.

**Hyprland/niri fails to start on first login**
Ctrl+Alt+F1 to TTY1, log in as `pep0`, check
`journalctl --user -u graphical-session.target` (or look at greetd
logs with `journalctl -u greetd`). Usually a missing package or a
typo in a `programs.niri.config` line.

**Lanzaboote refuses to enroll keys**
Either Setup Mode wasn't enabled (re-check 10c) or BIOS persisted
keys you didn't wipe. In BIOS: "Restore Factory Keys", then "Reset
to Setup Mode" / "Clear All Secure Boot Settings", save, retry 10e.

**TPM enrolment "no TPM2 device found"**
TPM might be disabled in BIOS — F1 → Security → Security Chip
→ make sure it's "Active". Save and retry 11c.

# Secure Boot setup (Lanzaboote)

Do this **after** the first successful boot, not during install.

## Why

Secure Boot ensures only kernels and bootloaders signed with your keys
can run at startup. Combined with LUKS, it closes the "evil maid"
attack — someone with physical access can't tamper with your boot
chain undetected. Doesn't help against attacks after boot; pair it
with a strong BIOS password.

## Prerequisites

- System installed in UEFI mode with systemd-boot (the default in
  `boot.nix`).
- A BIOS password set. Without one, an attacker can just disable
  Secure Boot in firmware.
- LUKS already on (you have this).

Verify the system is ready:
```
sudo bootctl status
```
You want `Firmware: UEFI ...` and `Current Boot Loader: systemd-boot`.

## Steps

1. **Generate keys**:
   ```
   sudo sbctl create-keys
   ```
   Keys land in `/var/lib/sbctl`.

2. **Switch BIOS to Setup Mode.** ThinkPad: reboot, F1 to enter BIOS,
   `Security` → `Secure Boot` → set to *Enabled*, then *Reset to
   Setup Mode*. F10 to save and exit.

3. **Enable lanzaboote** in `modules/system/secureboot.nix`:
   - flip `boot.lanzaboote.enable` to `true`
   - set `pkiBundle = "/var/lib/sbctl";`
   - uncomment the `boot.loader.systemd-boot.enable = lib.mkForce false;` line

4. **Rebuild and reboot**:
   ```
   make system
   sudo reboot
   ```

5. **Enroll your keys** (first boot after the rebuild):
   ```
   sudo sbctl enroll-keys --microsoft
   ```
   The `--microsoft` flag also enrolls Microsoft's third-party keys so
   OptionROMs (some hardware uses these during boot) still load.

6. **Re-enable Secure Boot** in BIOS, then reboot one more time.

7. **Verify**:
   ```
   sudo sbctl status
   ```
   You want `Secure Boot: enabled (user)` and `Setup Mode: disabled`.

   Also:
   ```
   sudo sbctl verify
   ```
   Every relevant binary should show `signed`.

## If something goes wrong

You can always boot the NixOS installer ISO, mount your disks, and
either flip the lanzaboote settings back or chroot in and rebuild. The
keys in `/var/lib/sbctl` are yours — back them up if you care about
not regenerating them on a reinstall.

# TPM2 auto-unlock for LUKS

Bind your LUKS root partition to the TPM2 so the disk unlocks
automatically when (and only when) the boot chain is what you
enrolled. No passphrase typing on every boot; passphrase still works
as a fallback.

This only makes sense **after** Lanzaboote / Secure Boot is enrolled
(see [SECUREBOOT.md](SECUREBOOT.md)). The TPM trusts the boot chain
via PCR 7 — which encodes "Secure Boot is on with these specific
keys". Without SB enrolled, PCR 7 is meaningless and the protection
is theatre.

Applies to `vifslan` only (the ThinkPad). `tofslan` (MacBook Pro Mid
2014) has no usable TPM2 chip.

## Why PCR 7

The boot chain measures multiple PCRs as it goes. We bind only to
PCR 7 because:

- It **doesn't change** when you update the kernel, Lanzaboote, or
  the UKI — those are all signed by your SB keys, and PCR 7 only
  cares about *which keys are trusted*, not the artifact content.
- It **does change** if Secure Boot is disabled, keys are removed,
  the firmware key database is replaced, or someone enrolls a
  different key set.

PCR 0/2/4/11 would bind to firmware code, OptionROMs, bootloader, or
UKI contents — stricter but you'd have to re-enroll on every firmware
or kernel update. Not worth it for a personal laptop.

## Prerequisites

- LUKS is already on the root partition (from the initial install).
- Lanzaboote / Secure Boot is enrolled. Verify:
  ```
  sudo sbctl status
  # → Secure Boot: enabled (user)
  # → Setup Mode: disabled
  ```
- The TPM2 chip is present and active. Verify:
  ```
  sudo dmesg | grep -i tpm
  ls /dev/tpm*           # /dev/tpm0 and /dev/tpmrm0 should exist
  ```
- This flake's `modules/system/tpm-unlock.nix` is imported by the
  host (already wired into `hosts/vifslan/default.nix`).

## Steps

1. **Apply the config so the initrd has systemd + TPM support**:
   ```
   make system
   sudo reboot
   ```
   On reboot, you'll still be prompted for the LUKS passphrase —
   nothing's enrolled in the TPM yet, so it falls back. Good: confirms
   the fallback works.

2. **Enroll the TPM** against PCR 7. You'll be asked for an existing
   LUKS passphrase to authorize creating the new keyslot:
   ```
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
   ```
   Replace `/dev/nvme0n1p2` with your encrypted partition (check with
   `lsblk` — it's the LUKS device with `crypto_LUKS` filesystem). The
   enrolment creates a new keyslot containing a random key sealed to
   PCR 7; the TPM releases the key only when PCR 7 matches at boot.

3. **Reboot**:
   ```
   sudo reboot
   ```
   This time, **no passphrase prompt** — systemd-cryptsetup queries
   the TPM, PCR 7 matches, the key drops out, LUKS unlocks, boot
   proceeds.

4. **Verify** an enrolled keyslot is bound to the TPM:
   ```
   sudo systemd-cryptenroll /dev/nvme0n1p2
   ```
   You should see at least two slots — one `password` (your
   original) and one `tpm2`.

## What to do when

### Re-enrolling after a Secure Boot key change

If you ever run `sbctl enroll-keys` again, regenerate keys with
`sbctl create-keys`, or BIOS resets the key database, PCR 7 changes.
Boot falls back to passphrase. To restore auto-unlock:

```
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```

### Removing TPM unlock entirely

```
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
```
Then optionally drop the module import from `hosts/vifslan/default.nix`
and remove `modules/system/tpm-unlock.nix`.

### Locking out the passphrase (don't)

`systemd-cryptenroll` can wipe the password slot too, leaving only
TPM. **Don't.** If the motherboard dies or you reset the TPM, you
lose the disk. Keep a working passphrase slot.

## Threat model — what TPM unlock does and doesn't do

**Protects against:**

- Someone with physical access who powers on the laptop and tries to
  read the disk without the passphrase. TPM won't release the key
  unless PCR 7 matches *your* boot chain. They can't just swap in a
  modified bootloader, kernel, or initrd — that changes the measured
  chain (Lanzaboote verifies, SB rejects unsigned).
- "Evil maid" attempts that try to backdoor the bootloader: the
  signature check fails, system doesn't boot, TPM is never queried.

**Does not protect against:**

- An attacker who already has the passphrase (the fallback slot still
  works).
- An attacker who is logged in as root post-boot — they can read
  the disk freely; TPM only gates pre-boot access.
- DMA attacks via Thunderbolt while the system is running with the
  disk decrypted. (Mitigation: enable IOMMU and lock the BIOS.)
- A firmware-level rootkit that lies to the TPM. (Mitigation: BIOS
  supervisor password, signed firmware updates via fwupd.)

## If TPM unlock breaks

The passphrase fallback always works. If you see the passphrase
prompt unexpectedly, it means PCR 7 changed — usually after:

- BIOS update (firmware key database may have shifted)
- BIOS reset to defaults
- Secure Boot was toggled off and back on
- `sbctl` operations that re-enroll keys

Just type the passphrase and re-enroll TPM as in the "re-enrolling"
section above.

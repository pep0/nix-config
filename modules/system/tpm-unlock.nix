{ pkgs, ... }:
{
  # TPM2-backed LUKS auto-unlock. Pairs with Lanzaboote: the boot chain
  # is measured into PCR 7 (Secure Boot state + keys), and the TPM
  # only releases the LUKS key when PCR 7 matches what was enrolled.
  # If anything in the chain changes — SB disabled, keys replaced,
  # firmware tampered — the TPM refuses and the boot drops back to
  # the passphrase prompt. See TPM-UNLOCK.md for the enrolment steps.

  # systemd-in-initrd is required: the legacy initrd has no TPM2
  # support. systemd-cryptsetup honors `tpm2-device=auto` automatically.
  boot.initrd.systemd.enable = true;

  # Try the TPM first; on PCR mismatch / no enrolled key, fall back to
  # the passphrase prompt. Safe to enable preemptively — the device
  # name `cryptroot` matches what `nixos-generate-config` produces.
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

  # Post-boot TPM tooling. `tpm2_pcrread` for inspecting PCR values;
  # `systemd-cryptenroll` is in systemd itself.
  environment.systemPackages = with pkgs; [ tpm2-tools ];

  # User-space TPM stack: enables the resource broker, lets non-root
  # tools reach the TPM for some operations.
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;          # PKCS#11 token for SSH keys bound to TPM
    tctiEnvironment.enable = true; # exports TCTI for userspace tools
  };
}

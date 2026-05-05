{ pkgs, lib, ... }:
{
  # ---------------------------------------------------------------
  # Secure Boot via Lanzaboote.
  #
  # READ SECUREBOOT.md BEFORE ENABLING. The first install must boot
  # with systemd-boot (boot.nix) so the machine works at all. Once
  # you're booted in, you:
  #
  #   1. Set a BIOS password.
  #   2. Generate keys with `sudo sbctl create-keys`.
  #   3. Switch BIOS to "Setup Mode" + clear factory keys.
  #   4. Set `boot.lanzaboote.enable = true` below (or via the lib.mkForce
  #      block being uncommented), rebuild, reboot.
  #   5. Enroll your keys: `sudo sbctl enroll-keys --microsoft`.
  #   6. Re-enable Secure Boot in BIOS.
  #
  # The --microsoft flag keeps Microsoft's third-party keys around so
  # OptionROMs (some GPUs, fingerprint readers, etc.) still load.
  # ---------------------------------------------------------------

  environment.systemPackages = [ pkgs.sbctl ];

  # Until you've enrolled keys, keep this off. Flipping it before
  # enrolment will leave you with an unbootable system.
  boot.lanzaboote = {
    enable = false;
    # enable = true;
    # pkiBundle = "/var/lib/sbctl";
  };

  # When lanzaboote is on, it owns the bootloader — disable systemd-boot
  # so the modules don't fight. The mkForce overrides boot.nix's default.
  # Uncomment this block at the same time you flip enable above.
  #
  # boot.loader.systemd-boot.enable = lib.mkForce false;
}

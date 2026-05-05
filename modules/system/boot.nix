{ pkgs, lib, ... }:
{
  # Lanzaboote (in modules/system/secureboot.nix) replaces systemd-boot
  # once enrolled. For the *first* install, leave systemd-boot enabled
  # so the machine can boot at all — then follow SECUREBOOT.md to
  # enroll keys and flip over.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # last 10 generations in the boot menu

  # LUKS unlock at boot. nixos-generate-config usually populates this
  # in hardware-configuration.nix already; if it does, delete this block
  # and let that file own it.
  #
  # boot.initrd.luks.devices."cryptroot" = {
  #   device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-UUID";
  #   preLVM = true;
  #   allowDiscards = true;  # only enable on SSDs
  # };

  # Latest kernel from the flake's pinned nixpkgs. Using `pkgs` (not
  # `import <nixpkgs>`) keeps the version reproducible via flake.lock.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}

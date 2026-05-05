{ ... }:
{
  imports = [
    # Generated for you by `nixos-generate-config` during install.
    ./hardware-configuration.nix

    ../../modules/system/boot.nix
    ../../modules/system/secureboot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/nix.nix
    ../../modules/system/users.nix
    ../../modules/system/audio.nix
    ../../modules/system/security.nix
    ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "default";

  # Set this to the release you first installed and never touch it again
  # — it pins stateful defaults (database formats, etc).
  system.stateVersion = "25.11";
}

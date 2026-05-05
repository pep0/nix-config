{ ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./hyprland.nix
  ];

  home.username = "tuna";
  home.homeDirectory = "/home/tuna";

  # Match this to system.stateVersion in hosts/default.
  # Same warning: set once at install, never change.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}

{ ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./hyprland.nix
    ./niri.nix
  ];

  home.username = "pep0";
  home.homeDirectory = "/home/pep0";

  # Match this to system.stateVersion in hosts/default.
  # Same warning: set once at install, never change.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}

{ username, stateVersion, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./cli-tools.nix
    ./gtk.nix
    ./wayland-apps.nix
    ./waybar.nix
    ./hyprland.nix
    ./niri.nix
    ./browser.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  programs.home-manager.enable = true;
}

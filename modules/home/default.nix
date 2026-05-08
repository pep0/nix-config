{ username, stateVersion, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./wayland-apps.nix
    ./hyprland.nix
    ./niri.nix
    ./browser.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  programs.home-manager.enable = true;
}

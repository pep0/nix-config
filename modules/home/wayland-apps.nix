{ pkgs, ... }:
{
  # Shared between Hyprland and niri: apps that compositor binds spawn
  # plus hardware-control utilities. Each compositor module adds its
  # own extras (wofi, etc.) on top.

  home.packages = with pkgs; [
    kitty
    waybar
    grim
    slurp
    wl-clipboard
    brightnessctl
    pavucontrol
    swaylock
  ];
}

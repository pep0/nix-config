{ pkgs, inputs, ... }:
{
  # Use the flake's Hyprland rather than the one in nixpkgs. The
  # Hyprland devs explicitly recommend this — nixpkgs lags and they
  # don't support old versions when bug-hunting.
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };
}

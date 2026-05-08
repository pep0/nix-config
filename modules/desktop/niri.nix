{ inputs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

  # Pulls in niri itself, the .desktop session file (so tuigreet lists
  # it), and the niri-specific xdg-desktop-portal. Stylix also has a
  # `targets.niri` integration that themes niri to match base16Scheme,
  # enabled by default once stylix sees niri active.
  programs.niri.enable = true;
}

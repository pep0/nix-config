{ pkgs, inputs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

  # Pulls in niri itself, the .desktop session file (so ReGreet lists
  # it), and the niri-specific xdg-desktop-portal. Stylix also has a
  # `targets.niri` integration that themes niri to match base16Scheme,
  # enabled by default once stylix sees niri active.
  programs.niri.enable = true;

  # niri (25.08+) starts it on demand to give X11-only apps a $DISPLAY.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  # niri-flake ships its own polkit-kde agent wanted by niri.service, and
  # modules/home/niri.nix spawns hyprpolkitagent. Only one agent can
  # register per subject, so the loser exits and burns its restart limit
  # — whichever won the race. Keep hyprpolkitagent, drop this one.
  systemd.user.services.niri-flake-polkit.enable = false;
}

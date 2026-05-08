{ pkgs, lib, inputs, ... }:
let
  theme = import ../theme;
  # Hyprland wants colors as `rgb(rrggbb)` — strip the `#` and wrap.
  rgb = c: "rgb(${builtins.substring 1 6 c})";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Same package as the system module — keeps versions in lockstep.
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    # Minimal sane defaults. Once you boot in, use `hyprctl monitors`
    # to see what's connected and edit accordingly.
    settings = {
      monitor = ",preferred,auto,1";

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      exec-once = [
        "waybar"
      ];

      general = {
        # mkForce wins the conflict with stylix's hyprland target,
        # which would otherwise set its own base16-derived border colors.
        "col.active_border" = lib.mkForce "${rgb theme.colors.mauve} ${rgb theme.colors.blue} 45deg";
        "col.inactive_border" = lib.mkForce (rgb theme.colors.surface0);
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
      };

      decoration = {
        rounding = 8;
      };

      bind = [
        "$mod, Q, exec, $terminal"
        "$mod, C, killactive"
        "$mod, M, exit"
        "$mod, R, exec, $menu"

        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
      ];

      # Drag windows with the mouse.
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Bare-minimum desktop apps so a fresh login isn't unusable.
  home.packages = with pkgs; [
    kitty
    wofi
    waybar
    grim slurp wl-clipboard   # screenshots + clipboard
    brightnessctl
    pavucontrol
  ];
}

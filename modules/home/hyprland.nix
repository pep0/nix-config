{ pkgs, lib, config, inputs, ... }:
let
  # Stylix exposes the loaded base16 scheme as plain hex strings (no `#`).
  # Hyprland wants `rgb(rrggbb)`.
  c = name: "rgb(${config.lib.stylix.colors.${name}})";
in
{
  # Hyprland-only extras. Shared apps live in modules/home/wayland-apps.nix.
  home.packages = with pkgs; [ wofi ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    settings = {
      monitor = ",preferred,auto,1";

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      exec-once = [
        "waybar"
      ];

      general = {
        # mkForce wins the conflict with stylix's hyprland target so
        # the gradient survives. base0E = mauve, base0D = blue,
        # base02 = surface in tinted-theming's base16 mapping.
        "col.active_border" = lib.mkForce "${c "base0E"} ${c "base0D"} 45deg";
        "col.inactive_border" = lib.mkForce (c "base02");
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
        "$mod, B, exec, zen"

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
}

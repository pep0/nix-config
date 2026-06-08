{ pkgs, lib, config, inputs, ... }:
let
  # Stylix exposes the loaded base16 scheme as plain hex strings (no `#`).
  # Hyprland wants `rgb(rrggbb)`.
  c = name: "rgb(${config.lib.stylix.colors.${name}})";
in
{
  # Hyprland-only extras. Shared apps (kitty, waybar, mako, fuzzel,
  # hyprlock, swayidle …) live in modules/home/wayland-apps.nix.

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    # home-manager 26.05 defaults configType to "lua"; we render
    # settings via the attrset → hyprlang path.
    configType = "hyprlang";

    settings = {
      monitor = ",preferred,auto,1";

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$browser" = "zen";
      "$menu" = "fuzzel";
      "$filemanager" = "thunar";

      exec-once = [
        "waybar"
        "mako"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
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
        # App launches
        "$mod, return, exec, $terminal"
        "$mod, D,      exec, $menu"
        "$mod, B,      exec, $browser"
        "$mod, E,      exec, $filemanager"
        "$mod, P,      exec, powermenu"
        "$mod, N,      exec, makoctl dismiss --all"
        "$mod, escape, exec, hyprlock"

        # Window management
        "$mod, Q,            killactive"
        "$mod, F,            fullscreen, 1"     # maximize-ish (keeps gaps)
        "$mod SHIFT, F,      fullscreen, 0"     # true fullscreen
        "$mod, space,        togglefloating"

        # Screenshot
        ", Print,             exec, screenshot --copy"
        "$mod SHIFT, S,       exec, screenshot --copy"
        "$mod, Print,         exec, screenshot --save"
        "$mod SHIFT, Print,   exec, screenshot --swappy"

        # Focus — arrows + hjkl
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, H,     movefocus, l"
        "$mod, J,     movefocus, d"
        "$mod, K,     movefocus, u"
        "$mod, L,     movefocus, r"

        # Move window — arrows + hjkl
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        "$mod SHIFT, H,     movewindow, l"
        "$mod SHIFT, J,     movewindow, d"
        "$mod SHIFT, K,     movewindow, u"
        "$mod SHIFT, L,     movewindow, r"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
      ];

      # Media + brightness keys. `e` (release) lets the bind repeat.
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      bindl = [
        ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay,         exec, playerctl play-pause"
        ", XF86AudioNext,         exec, playerctl next"
        ", XF86AudioPrev,         exec, playerctl previous"
      ];

      # Drag windows with the mouse.
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}

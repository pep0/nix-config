{ pkgs, config, ... }:
let
  c = name: "#${config.lib.stylix.colors.${name}}";
in
{
  # niri-flake's home-manager module is auto-propagated by the system
  # module (modules/desktop/niri.nix). Shared apps live in
  # modules/home/wayland-apps.nix; this file is niri-only.

  programs.niri.config = ''
    // See https://github.com/YaLTeR/niri/wiki/Configuration%3A-Overview
    // Stylix's niri target merges colors/fonts on top of this file.

    input {
        keyboard {
            xkb {
                layout "us,ch"
                variant ",de_nodeadkeys"
                options "grp:win_space_toggle"
            }
        }
        touchpad {
            tap
            natural-scroll
            click-method "clickfinger"
        }
        mouse {
            accel-profile "flat"
        }
        focus-follows-mouse
    }

    layout {
        gaps 8
        center-focused-column "never"
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }
        default-column-width { proportion 0.5; }
        focus-ring {
            width 2
            active-color "${c "base0E"}"
            inactive-color "${c "base02"}"
        }
    }

    prefer-no-csd
    spawn-at-startup "dbus-update-activation-environment" "--all"
    spawn-at-startup "swaybg" "-m" "fill" "-i" "${config.stylix.image}"
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
    spawn-at-startup "wl-clip-persist" "--clipboard" "regular"
    spawn-at-startup "poweralertd"

    binds {
        // App launches
        Mod+Return { spawn "kitty"; }
        Mod+D      { spawn "fuzzel"; }
        Mod+B      { spawn "firefox"; }
        Mod+E      { spawn "thunar"; }
        Mod+P      { spawn "powermenu"; }
        Mod+N      { spawn "makoctl" "dismiss" "--all"; }
        Mod+Escape { spawn "lock"; }

        // Window management
        Mod+Q       { close-window; }
        Mod+F       { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Shift+Space { toggle-window-floating; }
        Mod+W       { switch-preset-column-width; }
        Mod+Tab     { toggle-overview; }

        // Screenshot
        Print              { spawn "screenshot" "--copy"; }
        Mod+Shift+S        { spawn "screenshot" "--copy"; }
        Mod+Print          { spawn "screenshot" "--save"; }
        Mod+Shift+Print    { spawn "screenshot" "--swappy"; }

        // Focus — arrows + hjkl; spills over to adjacent monitor at the edge
        Mod+Left  { focus-column-or-monitor-left; }
        Mod+Right { focus-column-or-monitor-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }
        Mod+H     { focus-column-or-monitor-left; }
        Mod+J     { focus-window-or-workspace-down; }
        Mod+K     { focus-window-or-workspace-up; }
        Mod+L     { focus-column-or-monitor-right; }

        // Move column / window — arrows + hjkl; spills over to adjacent monitor at the edge
        Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
        Mod+Shift+Right { move-column-right-or-to-monitor-right; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+H     { move-column-left-or-to-monitor-left; }
        Mod+Shift+J     { move-column-to-workspace-down; }
        Mod+Shift+K     { move-column-to-workspace-up; }
        Mod+Shift+L     { move-column-right-or-to-monitor-right; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }

        // Media + brightness keys
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }
    }
    output "Dell Inc. DELL U2421E 7K69DP3" {
    mode "1920x1200@59.950"
    scale 1.0
    position x=0 y=0
    }
    output "Dell Inc. DELL U2421E 9K69DP3" {
        mode "1920x1200@59.950"
        scale 1.0
        position x=1920 y=0
    }
  '';
}

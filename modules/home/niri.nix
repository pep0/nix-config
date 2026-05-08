{ pkgs, config, ... }:
let
  c = name: "#${config.lib.stylix.colors.${name}}";
  polkitAgent = "${pkgs.lxqt.lxqt-policykit}/libexec/lxqt-policykit-agent";
in
{
  # niri-flake's home-manager module is auto-propagated by the system
  # module (modules/desktop/niri.nix). Shared apps live in
  # modules/home/wayland-apps.nix; this file is niri-only.

  home.packages = with pkgs; [ wofi ];

  programs.niri.config = ''
    // See https://github.com/YaLTeR/niri/wiki/Configuration%3A-Overview
    // Stylix's niri target merges colors/fonts on top of this file.

    input {
        keyboard {
            xkb {
                layout "us"
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
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "${polkitAgent}"

    binds {
        // App launches — match Hyprland's bindings where it makes sense.
        Mod+Q { spawn "kitty"; }
        Mod+R { spawn "wofi" "--show" "drun"; }
        Mod+B { spawn "zen"; }
        Mod+C { close-window; }
        Mod+M { quit; }

        // Focus
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        // Move windows
        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Down  { move-window-down; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }

        // Column-width niri specifics — no Hyprland equivalent
        Mod+W { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Screenshot + lock
        Print { screenshot; }
        Mod+Ctrl+Q { spawn "swaylock"; }

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
  '';
}

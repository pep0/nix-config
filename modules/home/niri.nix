{ pkgs, ... }:
let
  theme = import ../theme;
in
{
  # niri-flake's home-manager module is auto-propagated by the system
  # module (modules/desktop/niri.nix) — don't import it again here.
  # It owns ~/.config/niri/config.kdl and lets stylix layer its
  # theming on top.

  home.packages = with pkgs; [
    # Default-binding apps need to exist on PATH at session start.
    kitty
    wofi
    waybar
    grim
    slurp
    wl-clipboard
    swaybg            # niri doesn't paint a background itself
    swaylock          # for the lock-screen bind
  ];

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
            active-color "${theme.colors.mauve}"
            inactive-color "${theme.colors.surface0}"
        }
    }

    prefer-no-csd
    spawn-at-startup "waybar"
    spawn-at-startup "swaybg" "-i" "/dev/null" "-c" "${theme.colors.base}"

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

        // Screenshot
        Print { screenshot; }

        // Lock
        Mod+Ctrl+Q { spawn "swaylock"; }
    }
  '';
}

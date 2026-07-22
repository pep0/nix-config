{ pkgs, config, inputs, ... }:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  # Stylix derives a coherent theme (colors + fonts + cursor) and applies
  # it system-wide and to home-manager. It targets a long list of apps —
  # GTK, Qt, kitty, alacritty, hyprland, waybar, helix, etc. — out of the
  # box. Disable individual targets via `stylix.targets.<name>.enable`.
  stylix = {
    enable = true;
    polarity = "dark";

    # Pinning the scheme keeps colors stable regardless of the wallpaper.
    # base16-schemes ships hundreds of YAML schemes — swap the filename
    # to e.g. `catppuccin-mocha.yaml`, `gruvbox-dark-medium.yaml`, or
    # `tokyo-night-storm.yaml` to change the entire system theme.
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/qualia.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

    image = pkgs.fetchurl {
      url = "https://static.simpledesktops.com/uploads/desktops/2017/02/07/traffic.png";
      hash = "sha256-ThvTekcP2fUBEwa5GfpFE7jUwxBF+Gl0St7EUGnVtsQ=";
    };

    # Without this, stylix falls back to whatever cursor theme happens
    # to be installed (often a low-res default) — Bibata is crisp at
    # HiDPI sizes and themes consistently across GTK/Qt.
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        terminal = 10;
        desktop = 10;
        popups = 10;
      };
    };
  };
}

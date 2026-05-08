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
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Stylix requires an `image` (used as desktop wallpaper). With a
    # base16Scheme set, the image isn't used to derive colors. The
    # `pixel` helper returns a 1×1 PNG of the named base16 color —
    # cheap placeholder until you drop a real wallpaper here.
    image = config.lib.stylix.pixel "base00";

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
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };
  };
}

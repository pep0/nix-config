{ pkgs, config, inputs, ... }:
let
  # Bound once and used for both options below: reading
  # `config.stylix.base16Scheme` from inside the wallpaper derivation would
  # tangle the scheme with the image stylix can derive a scheme *from*.
  base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  # Stylix derives a coherent theme (colors + fonts + cursor) and applies
  # it system-wide and to home-manager. It targets a long list of apps —
  # GTK, Qt, kitty, alacritty, hyprland, waybar, helix, etc. — out of the
  # box. Disable individual targets via `stylix.targets.<name>.enable`.
  stylix = {
    enable = true;
    polarity = "dark";

    # base16-schemes ships hundreds of YAML schemes — swap the filename in
    # the `let` above to e.g. `catppuccin-mocha.yaml`,
    # `gruvbox-dark-medium.yaml` or `tokyo-night-storm.yaml` to change the
    # entire system theme, wallpaper included.
    inherit base16Scheme;

    # Regenerated from the scheme rather than downloaded, so it follows the
    # theme. The layout comes from pkgs/wallpaper/seed, which `make system`
    # re-rolls; `make wallpaper` previews a new one without switching.
    image = pkgs.callPackage ../../pkgs/wallpaper { inherit base16Scheme; };

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

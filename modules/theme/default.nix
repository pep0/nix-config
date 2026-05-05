{
  # Centralized color palette. Reference from any module via
  # `(import ../theme).colors.foo` or by passing it through specialArgs.
  #
  # Currently Tokyo Night Dark — to switch palettes, replace the values
  # below and update `stylix.base16Scheme` in modules/system/stylix.nix
  # to match. The names are catppuccin-flavored aliases so the rest of
  # the config doesn't need to know which palette is loaded.
  colors = {
    base       = "#1a1b26";
    mantle     = "#16161e";
    crust      = "#15161e";

    text       = "#c0caf5";
    subtext1   = "#a9b1d6";
    subtext0   = "#9aa5ce";

    surface0   = "#292e42";
    surface1   = "#414868";
    surface2   = "#565f89";

    overlay0   = "#565f89";
    overlay1   = "#787c99";
    overlay2   = "#9aa5ce";

    blue       = "#7aa2f7";
    lavender   = "#7dcfff";
    sapphire   = "#2ac3de";
    sky        = "#b4f9f8";
    teal       = "#73daca";
    green      = "#9ece6a";
    yellow     = "#e0af68";
    peach      = "#ff9e64";
    maroon     = "#f7768e";
    red        = "#f7768e";
    mauve      = "#bb9af7";
    pink       = "#ad8ee6";
    flamingo   = "#ff9e64";
    rosewater  = "#f7768e";
  };

  fonts = {
    mono = "JetBrainsMono Nerd Font";
    sans = "Noto Sans";
  };
}

{ ... }:
{
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  # Wayland keymaps are owned by each compositor's config (both already
  # set xkb layout = "us"); xserver.xkb.layout would only matter under X.
}


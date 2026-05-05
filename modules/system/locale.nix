{ ... }:
{
  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";
  services.xserver.xkb.layout = "us";  # also covers Wayland sessions
}

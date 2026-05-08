{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Tray applet for pairing/connecting from the desktop.
  services.blueman.enable = true;
}

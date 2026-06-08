{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Experimental flag enables newer BlueZ features — most notably
    # LE Audio (BLE audio) for compatible headphones/earbuds.
    settings.General.Experimental = true;
  };

  # Tray applet for pairing/connecting from the desktop.
  services.blueman.enable = true;
}

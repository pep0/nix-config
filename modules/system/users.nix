{ pkgs, ... }:
{
  users.users.pep0 = {
    isNormalUser = true;
    description = "pep0";
    extraGroups = [
      "wheel"            # sudo
      "networkmanager"   # nmcli without root
      "video"            # backlight, GPU
      "audio"            # ALSA/Pipewire device access
    ];
    shell = pkgs.nushell;
  };

  # Set an initial password with `passwd` after first boot.
  # Don't ship a real password in source control.
}

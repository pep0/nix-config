{ ... }:
{
  networking.networkmanager.enable = true;

  # Defaults to firewall on, no ports open. Open as needed.
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 22 ];
}

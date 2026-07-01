{ pkgs, ... }:
{
  networking.networkmanager.enable = true;

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeText "wifi-wired-exclusive" ''
        if [ "$2" = "up" ] || [ "$2" = "down" ]; then
          has_wired=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE dev | grep 'ethernet:connected' | grep -c .)
          if [ "$has_wired" -gt 0 ]; then
            ${pkgs.networkmanager}/bin/nmcli radio wifi off
          else
            ${pkgs.networkmanager}/bin/nmcli radio wifi on
          fi
        fi
      '';
      type = "basic";
    }
  ];


  # Defaults to firewall on, no ports open. Open as needed.
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 22 ];
}

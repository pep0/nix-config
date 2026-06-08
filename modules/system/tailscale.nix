{ ... }:
{
  # Tailscale mesh VPN. Just enables the service — you'll run
  # `sudo tailscale up --ssh` interactively to authenticate. The
  # firewall opens UDP/41641 automatically when tailscale starts.
  services.tailscale.enable = true;
}

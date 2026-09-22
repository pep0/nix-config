{ ... }:
{
  # Tailscale mesh VPN. Just enables the service — you'll run
  # `sudo tailscale up --ssh` interactively to authenticate.
  services.tailscale.enable = true;

  # sshd is firewalled off everywhere else (services.nix); this is what
  # lets the mesh still reach it.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}

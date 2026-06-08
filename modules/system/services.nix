{ ... }:
{
  # OpenSSH daemon. The firewall is on with no ports open, so port 22
  # stays blocked at the network boundary — you can ssh OUT and (with
  # tailscale up) reach this host over the mesh, but unsolicited inbound
  # from the public internet is dropped.
  services.openssh.enable = true;

  # Periodic SSD trim (weekly by default).
  services.fstrim.enable = true;

  # Battery / AC events. poweralertd in the user profile subscribes for
  # low-battery notifications; without upower nothing would publish them.
  services.upower.enable = true;

  # Don't suspend the moment the power button is tapped — route it
  # through the powermenu instead (Mod+P).
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Don't wait the systemd default 90s on a hanging unit at shutdown.
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}

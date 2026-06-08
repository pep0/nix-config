{ ... }:
{
  # systemd watchdog. If pid1 stops responding for `RuntimeWatchdogSec`,
  # the kernel reboots the machine. Cheap insurance against rare hangs.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
  systemd.settings.Manager.RebootWatchdogSec  = "5min";
  systemd.settings.Manager.KExecWatchdogSec   = "5min";
}

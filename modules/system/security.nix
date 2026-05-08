{ ... }:
{
  # AppArmor: kernel-level mandatory access control. If a service
  # breaks under enforcement, check `journalctl -k | grep DENIED`.
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  # auditd records security-relevant events; useful for debugging
  # AppArmor denials.
  security.auditd.enable = true;

  # Firmware updates from LVFS (ThinkPad/most modern hardware ships
  # firmware here). MacBook gets little benefit but it's harmless.
  services.fwupd.enable = true;
}

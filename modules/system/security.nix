{ ... }:
{
  # AppArmor: kernel-level mandatory access control. Limits what
  # individual processes can touch regardless of file permissions.
  # Most NixOS-shipped profiles are conservative; if a service breaks
  # under enforcement, check `journalctl -k | grep DENIED` and either
  # add a profile exception or disable the offending profile.
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;  # apply existing profiles to running processes on activation
  };

  # auditd records security-relevant events. Useful for debugging
  # AppArmor denials and seeing what the system is actually doing.
  security.auditd.enable = true;
}

{ ... }:
{
  # TLP: laptop power-management daemon. CPU governor scaling, USB
  # autosuspend, PCIe ASPM, Wi-Fi power save, etc.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC      = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT     = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC    = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT   = "power";

      # PCIe Active State Power Management — aggressive on battery.
      PCIE_ASPM_ON_AC  = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Charge thresholds: stop charging at 80% on AC to extend battery
      # lifespan. Only honored on ThinkPads (the macbook silently
      # ignores these).
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0  = 80;
    };
  };

  # power-profiles-daemon conflicts with TLP — disable explicitly so a
  # future module change doesn't pull it in alongside.
  services.power-profiles-daemon.enable = false;
}

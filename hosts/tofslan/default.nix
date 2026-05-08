{ pkgs, config, inputs, stateVersion, ... }:
{
  imports = [
    # Generated for you by `nixos-generate-config` during install.
    ./hardware-configuration.nix

    # Hardware: MacBookPro11,1 — mid-2014 13" Retina, Haswell CPU,
    # Intel Iris 5100 (no dGPU). The nixos-hardware module pulls in
    # SSD tweaks, the haswell CPU profile, and redistributable firmware.
    inputs.nixos-hardware.nixosModules.apple-macbook-pro-11-1

    # No `secureboot.nix` here — Apple firmware doesn't support
    # user-enrolled Secure Boot keys reliably, so this host stays on
    # systemd-boot and skips lanzaboote entirely.
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/nix.nix
    ../../modules/system/users.nix
    ../../modules/system/audio.nix
    ../../modules/system/security.nix
    ../../modules/system/secrets.nix
    ../../modules/system/stylix.nix
    ../../modules/system/bluetooth.nix
    ../../modules/system/power.nix
    ../../modules/desktop                 # generic Wayland infrastructure
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/niri.nix
  ];

  networking.hostName = "tofslan";
  system.stateVersion = stateVersion;

  # ---------------------------------------------------------------
  # GPU: Intel Iris 5100 (Haswell) only. The legacy `i965` VAAPI
  # driver covers Haswell — `iHD` is Broadwell+ and won't work here.
  # ---------------------------------------------------------------
  hardware.graphics.extraPackages = with pkgs; [
    intel-vaapi-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "i965";
  };

  # ---------------------------------------------------------------
  # Wi-Fi: Broadcom BCM4360. Needs the proprietary STA driver — the
  # in-tree `b43` and `brcmfmac` won't bring this card up.
  # ---------------------------------------------------------------
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # Block the in-tree drivers so they don't fight `wl` for the device.
  boot.blacklistedKernelModules = [ "b43" "bcma" "brcmfmac" "brcmsmac" ];

  # broadcom-sta is unmaintained and flagged insecure by nixpkgs. It's
  # the only Wi-Fi option for BCM4360 — accepting that risk knowingly.
  # Predicate (not a fixed version list) so kernel bumps don't require
  # updating a version string after every rebuild.
  nixpkgs.config.allowInsecurePredicate = pkg:
    pkgs.lib.getName pkg == "broadcom-sta";

  # Pin to LTS — broadcom-sta routinely fails to build against the
  # latest kernel for weeks after a bump. mkDefault in boot.nix lets
  # this win.
  boot.kernelPackages = pkgs.linuxPackages;

  # ---------------------------------------------------------------
  # Thermals: Linux's default fan curve runs the MacBook hotter than
  # macOS does. mbpfan ramps fans more aggressively above ~55°C.
  # ---------------------------------------------------------------
  services.mbpfan.enable = true;

  # ---------------------------------------------------------------
  # Known-broken / hard hardware:
  # - FaceTime HD camera (1c:8c:fa:00) needs the out-of-tree
  #   `bcwc-pcie` driver, which has been broken on modern kernels for
  #   years. Treat it as non-functional.
  # - The IR receiver and SD card slot generally work without extra
  #   config; ambient light sensor exposes via /sys/class/backlight.
  # ---------------------------------------------------------------
}

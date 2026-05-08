{ pkgs, inputs, stateVersion, ... }:
{
  imports = [
    # Generated for you by `nixos-generate-config` during install.
    ./hardware-configuration.nix

    # Hardware: ThinkPad P14s Gen 5 Intel — power management, ACPI,
    # firmware, PRIME for the hybrid Intel + NVIDIA GPU.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
    inputs.lanzaboote.nixosModules.lanzaboote

    ../../modules/system/boot.nix
    ../../modules/system/secureboot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/nix.nix
    ../../modules/system/users.nix
    ../../modules/system/audio.nix
    ../../modules/system/security.nix
    ../../modules/system/secrets.nix
    ../../modules/system/stylix.nix
    ../../modules/desktop                 # generic Wayland infrastructure
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/niri.nix
  ];

  networking.hostName = "default";
  system.stateVersion = stateVersion;

  # ---------------------------------------------------------------
  # GPU: hybrid Intel iGPU + NVIDIA dGPU via PRIME offload. Only
  # processes launched with `nvidia-offload` actually hit the dGPU;
  # display + the rest of the desktop runs on Intel.
  # ---------------------------------------------------------------
  hardware.graphics.extraPackages = with pkgs; [
    # iHD: Intel media driver for HEVC/AV1 decode on modern (Broadwell+)
    # iGPUs. Pairs with LIBVA_DRIVER_NAME below.
    intel-media-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Free win from nixos-hardware: adds a "battery-saver" generation to
  # the boot menu that boots with the dGPU fully off, for max battery
  # on the road.
  hardware.nvidia.primeBatterySaverSpecialisation = true;
}

{ pkgs, lib, config, inputs, stateVersion, ... }:
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
    ../../modules/system/bluetooth.nix
    ../../modules/system/power.nix
    ../../modules/system/watchdog.nix
    ../../modules/system/programs.nix
    ../../modules/system/services.nix
    ../../modules/system/tailscale.nix
    ../../modules/system/tpm-unlock.nix
    ../../modules/desktop                 # generic Wayland infrastructure
    ../../modules/desktop/niri.nix
  ];

  networking.hostName = "thinkpad";
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

  # GBM_BACKEND/__GLX_VENDOR_LIBRARY_NAME must NOT go here: this session
  # runs on Intel (see above), and forcing every process onto NVIDIA's
  # GBM/EGL path while niri scans out via Intel KMS corrupts WebRender's
  # glyph atlas compositing (Firefox chrome renders icons but no text).
  # The `nvidia-offload` wrapper already scopes the right vars to
  # processes that actually want the dGPU.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NVD_BACKEND = "direct";
  };

  # Linux 7.2 finished removing strncpy() from the kernel and renamed
  # drm_atomic_state -> drm_atomic_commit; nvidia-open 595 still uses both,
  # so its modules don't compile. CachyOS carries the backport. Drop this
  # block (it will then fail to apply, loudly) once nixpkgs ships a driver
  # that builds on 7.2 — see NVIDIA/open-gpu-kernel-modules#1224.
  hardware.nvidia.package =
    let
      base = config.boot.kernelPackages.nvidiaPackages.${config.hardware.nvidia.branch};
      kernel72Patch = pkgs.fetchurl {
        name = "nvidia-open-linux-7.2-support.patch";
        url = "https://github.com/CachyOS/CachyOS-PKGBUILDS/raw/94bcd86886298f7798837a38dc1ff361d60a9c8d/nvidia/nvidia-utils/0001-make-Add-support-for-7.2-Kernel.patch";
        hash = "sha256-hdklzeaY0s/0RME+CtQoddwOuTkSh+/jNdDD6t7cC48=";
      };
    in
    if lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.2" then
      base.overrideAttrs (old: {
        passthru = old.passthru // {
          open = old.passthru.open.overrideAttrs (o: {
            patches = (o.patches or [ ]) ++ [ kernel72Patch ];
          });
        };
      })
    else
      base;

  # Runtime D3: with PRIME offload, the dGPU sits powered-on-and-idle
  # unless something tells it to suspend. finegrained is that switch
  # (NVreg_DynamicPowerManagement=0x02 plus the runtime-PM udev rules),
  # and needs offload.enable, which nixos-hardware already sets.
  # powerManagement saves/restores VRAM across suspend, which this
  # machine does on every idle timeout.
  hardware.nvidia.powerManagement = {
    enable = true;
    finegrained = true;
  };

  # Free win from nixos-hardware: adds a "battery-saver" generation to
  # the boot menu that boots with the dGPU fully off, for max battery
  # on the road.
  hardware.nvidia.primeBatterySaverSpecialisation = true;

  # spd5118: DDR5 SPD sensor driver fails resume because its I2C bus
  # isn't ready in time — blacklisting silences the errors with no
  # functional loss (the chip is only used for memory temp monitoring).
  boot.blacklistedKernelModules = [ "spd5118" ];

  # i915: disable Panel Self-Refresh to stop AUX/USBC/MST handshake
  # failures when the Dell monitors resume over Thunderbolt/USB-C.
  boot.kernelParams = [ "i915.enable_psr=0" ];

  # boltd, to authorize the Thunderbolt 4 dock. The domain runs at
  # security level "user", so the dock stays at authorized=0 and its
  # PCIe functions — the ethernet NIC among them — never enumerate
  # until something approves it. DP alt-mode is below that layer, which
  # is why the monitors work on an unauthorized dock and the NIC does
  # not. Enroll once with `boltctl enroll <uuid>` to make it stick.
  services.hardware.bolt.enable = true;
}

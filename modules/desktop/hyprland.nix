{ pkgs, inputs, ... }:
{
  # Use the flake's Hyprland rather than the one in nixpkgs. The
  # Hyprland devs explicitly recommend this — nixpkgs lags and they
  # don't support old versions when bug-hunting.
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # OpenGL / graphics stack. Required for any compositor to do anything
  # interesting. The 32-bit shim is for Steam, Wine, etc.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # iHD: Intel media driver for HEVC/AV1 hardware decode on the iGPU.
      # Pairs with LIBVA_DRIVER_NAME below.
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Wayland + Nvidia env vars for the hybrid setup. With PRIME offload
  # active (configured by nixos-hardware's lenovo-thinkpad-p14s module),
  # only processes launched via `nvidia-offload` actually hit the dGPU.
  # These vars steer them correctly when they do.
  environment.sessionVariables = {
    # Video accel goes through the iGPU since Intel does the display.
    LIBVA_DRIVER_NAME = "iHD";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Free win from nixos-hardware: adds a "battery-saver" generation to
  # the boot menu that boots with the dGPU fully off, for max battery
  # on the road.
  hardware.nvidia.primeBatterySaverSpecialisation = true;

  # greetd + tuigreet: minimal TTY-style login manager. Replaces
  # SDDM/GDM, which are heavier and have their own Wayland quirks.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # XDG portals: how Wayland apps do file pickers, screen sharing, etc.
  # Hyprland portal handles screen-sharing; gtk handles file dialogs.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Polkit agent for GUI privilege prompts (mounting drives in a file
  # manager, etc). Without this, prompts silently fail under Hyprland.
  security.polkit.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}

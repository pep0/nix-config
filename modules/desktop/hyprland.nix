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
  # interesting. The 32-bit shim is for Steam, Wine, etc. Per-host
  # modules add hardware-specific drivers via
  # `hardware.graphics.extraPackages`.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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

  # Stylix installs the monospace/sans/serif/emoji packages declared in
  # its config — only add fonts here that stylix doesn't manage (e.g.
  # CJK, symbols-only).
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.symbols-only
  ];
}

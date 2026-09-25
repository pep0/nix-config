{ pkgs, lib, ... }:
{
  # Generic Wayland desktop infrastructure: graphics stack, login
  # manager, portals, polkit, fonts. Compositor-specific config lives
  # in niri.nix.

  # OpenGL / graphics stack. Required for any Wayland compositor.
  # Hardware-specific drivers (intel-media-driver, etc) come from
  # per-host `default.nix`. Re-enable `enable32Bit` if you ever add
  # Steam/Wine.
  hardware.graphics.enable = true;

  # Electron apps (Typora, Slack, Teams, ...) run natively on Wayland
  # instead of going through xwayland-satellite.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # greetd + tuigreet: minimal TTY-style login manager. Without --cmd
  # we get a session picker; `--remember-session` makes tuigreet land on
  # the last-picked one.
  #
  # ReGreet (GTK4 greeter in cage) was tried here instead: it authenticates
  # fine, but the chosen session (niri) exits within a second of the PAM
  # session opening and drops back to the greeter — no niri/cage error in
  # the journal, just an instant session close. Back to tuigreet until
  # that's root-caused.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --asterisks";
        user = "greeter";
      };
    };
  };

  # XDG portals: how Wayland apps do file pickers, screen sharing, etc.
  # niri has no native portal so we route ScreenCast/Screenshot through
  # gnome's portal, which works under any wlroots/wayland compositor.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
      niri = {
        # gtk doesn't need gnome-shell; gnome portal fails silently without it
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # Polkit agent for GUI privilege prompts (mounting drives in a file
  # manager, etc). Without this, prompts silently fail under Wayland.
  security.polkit.enable = true;

  # Stylix installs the monospace/sans/serif/emoji packages declared in
  # its config — only add fonts here that stylix doesn't manage (e.g.
  # CJK, symbols-only).
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.symbols-only
  ];
}

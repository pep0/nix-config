{ pkgs, lib, ... }:
{
  # Generic Wayland desktop infrastructure: graphics stack, login
  # manager, portals, polkit, fonts. Compositor-specific config lives
  # in sibling modules (hyprland.nix, niri.nix).

  # OpenGL / graphics stack. Required for any Wayland compositor.
  # Hardware-specific drivers (intel-media-driver, etc) come from
  # per-host `default.nix`. Re-enable `enable32Bit` if you ever add
  # Steam/Wine.
  hardware.graphics.enable = true;

  # greetd + tuigreet: minimal TTY-style login manager. Without --cmd
  # we get a session picker — the user arrows between Hyprland / niri.
  # `--remember-session` makes tuigreet land on the last-picked one.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --remember --remember-session --asterisks";
        user = "greeter";
      };
    };
  };

  # XDG portals: how Wayland apps do file pickers, screen sharing, etc.
  # Each compositor adds its own portal alongside this; gtk handles
  # generic file dialogs.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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

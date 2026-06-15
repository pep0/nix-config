{ pkgs, ... }:
{
  # Stylix sets `color-scheme=prefer-dark` (which GTK4/libadwaita honor),
  # but GTK3 apps using adw-gtk3 — Thunar, file pickers, openvpn-gnome —
  # only switch to the dark variant when this flag is explicitly set.
  # Without it, dialog buttons render dark-on-dark and are unreadable.
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = true;

  gtk.iconTheme = {
    package = pkgs.rose-pine-icon-theme;
    name = "rose-pine-moon";
  };
}

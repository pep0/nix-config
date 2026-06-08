{ pkgs, ... }:
{
  programs.ranger = {
    enable = true;
    settings = {
      show_hidden = true;
      preview_images = true;
    };
  };

  home.packages = with pkgs; [
    # Communication
    slack
    teams-for-linux

    # Image / document viewers
    loupe
    evince

    # Networking / VPN
    openvpn

    # Security
    keepassxc

    # Misc
    deluge          # torrent client
    remmina         # remote desktop
  ];

  # Keep Loupe the default image viewer (so installing other tools doesn't
  # silently steal the default handler for common image types).
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        loupe = "org.gnome.Loupe.desktop";
      in
      {
        "image/png"     = loupe;
        "image/jpeg"    = loupe;
        "image/gif"     = loupe;
        "image/webp"    = loupe;
        "image/bmp"     = loupe;
        "image/tiff"    = loupe;
        "image/svg+xml" = loupe;
        "image/avif"    = loupe;
      };
  };
}

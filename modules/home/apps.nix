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
    # WebKitGTK's DMA-BUF renderer silently drops image content (text/vector
    # still draws) on this hybrid Intel+NVIDIA laptop. Force it off for Foliate.
    (foliate.overrideAttrs (old: {
      postFixup = ''
        ${old.postFixup or ""}
        wrapProgram $out/bin/foliate --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      '';
    }))
    typora

    # Networking / VPN
    openvpn

    # Security
    keepassxc

    # Misc
    deluge          # torrent client
    remmina         # remote desktop
    dust
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

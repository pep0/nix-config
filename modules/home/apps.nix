{ pkgs, ... }:
{
  programs.ranger = {
    enable = true;
    settings = {
      show_hidden = true;
      preview_images = true;
    };
  };

  programs.mpv.enable = true;   # stylix themes it

  home.packages = with pkgs; [
    # Communication
    slack
    teams-for-linux
    tuba            # Mastodon

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

    # Diagrams
    drawio

    # Misc
    deluge          # torrent client
    remmina         # remote desktop
    dust
  ];

  # Pinned so installing other tools doesn't silently steal these handlers.
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        loupe = "org.gnome.Loupe.desktop";
        helix = "Helix.desktop";
        mpv = "mpv.desktop";
      in
      {
        "inode/directory"           = "thunar.desktop";

        "video/mp4"                 = mpv;
        "video/x-matroska"          = mpv;
        "video/webm"                = mpv;
        "video/quicktime"           = mpv;
        "video/x-msvideo"           = mpv;
        "video/mpeg"                = mpv;
        "audio/mpeg"                = mpv;
        "audio/flac"                = mpv;
        "audio/ogg"                 = mpv;
        "audio/x-wav"               = mpv;
        "audio/mp4"                 = mpv;
        "audio/opus"                = mpv;

        "text/plain"                = helix;
        "text/x-nix"                = helix;
        "text/x-log"                = helix;
        "text/csv"                  = helix;
        "text/x-python"             = helix;
        "text/rust"                 = helix;
        "application/json"          = helix;
        "application/yaml"          = helix;
        "application/x-yaml"        = helix;
        "application/toml"          = helix;
        "application/xml"           = helix;
        "application/x-shellscript" = helix;
        "application/x-zerosize"    = helix;

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

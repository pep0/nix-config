{ ... }:
{
  programs.firefox = {
    enable = true;
    # Pin pre-26.05 profile location so an existing profile (after the
    # 26.05 upgrade) keeps being picked up.
    configPath = ".mozilla/firefox";
    profiles.default = {
      isDefault = true;
      settings = {
        # Use xdg-desktop-portal for file pickers — without this Firefox
        # tries its own GTK dialog which fails under non-GTK compositors.
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Use portal for MIME handler (open-with dialogs).
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
      };
    };
  };

  stylix.targets.firefox.profileNames = [ "default" ];
}

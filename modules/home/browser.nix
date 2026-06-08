{ ... }:
{
  programs.firefox = {
    enable = true;
    # Pin pre-26.05 profile location so an existing profile (after the
    # 26.05 upgrade) keeps being picked up.
    configPath = ".mozilla/firefox";
    profiles.default.isDefault = true;
  };

  stylix.targets.firefox.profileNames = [ "default" ];
}

{ pkgs, ... }:
{
  # System-level program enables. Most of what you install is at the
  # home-manager layer (modules/home/...) — this is for programs that
  # need NixOS-level setup (suid wrappers, dbus services, file-manager
  # plugins, etc).

  programs.dconf.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Thunar (via exo) needs xfce4-mime-helper to launch its preferred
  # TerminalEmulator on "Open Terminal Here"; without `xfce4-settings`
  # it errors with "Could not find fallback TerminalEmulator application".
  environment.systemPackages = [ pkgs.xfce4-settings ];

  services.gvfs.enable = true;     # Thunar mounts, trash, network shares
  services.tumbler.enable = true;  # Thunar thumbnail generation
}

{ pkgs, ... }:
{
  # System-level program enables. Most of what you install is at the
  # home-manager layer (modules/home/...) — this is for programs that
  # need NixOS-level setup (suid wrappers, dbus services, file-manager
  # plugins, etc).

  programs.dconf.enable = true;

  # nix-ld: dynamic loader shim so pre-built non-Nix binaries (vendor
  # IDEs, vscode-server, some AppImages) can find their libs without
  # being wrapped/patched.
  programs.nix-ld.enable = true;

  # GPG agent for signing commits / decrypting with gpg keys. SSH
  # signing already works via OpenSSH; this is for GPG-only flows.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

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
  # xarchiver is the GUI backend that thunar-archive-plugin delegates to
  # for right-click extraction — without it "Extract Here" fails.
  environment.systemPackages = with pkgs; [
    xfce4-settings
    xarchiver
    # xarchiver shells out to these per format
    _7zz
    unrar
    unzip
    zip

    xdg-utils           # xdg-open, so Thunar can find default apps
    shared-mime-info    # type detection for text/plain and friends
  ];

  # What exo hands "Open Terminal Here". kitty comes from home-manager,
  # so it is on PATH in the session Thunar is launched from.
  environment.variables.TERMINAL = "kitty";

  # GLib launches Terminal=true entries (Helix.desktop) via xdg-terminal-exec;
  # its fallback list doesn't include kitty.
  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

  services.gvfs.enable = true;     # Thunar mounts, trash, network shares
  services.tumbler.enable = true;  # Thunar thumbnail generation
}

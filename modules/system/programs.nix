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

    # --- Extensions for Terminal & File Handlers ---
    xfce.xfce4-terminal # Or your preferred terminal like alacritty, kitty, etc.
    xdg-utils           # Provides xdg-open, helping Thunar find default apps
    shared-mime-info    # Helps systems correctly identify text/plain files
  ];

  # Force Thunar/Exo to recognize your global terminal preference
  environment.variables = {
    TERMINAL = "xfce4-terminal"; # Change this to "alacritty", "kitty", etc., if using a different one
  };

  services.gvfs.enable = true;     # Thunar mounts, trash, network shares
  services.tumbler.enable = true;  # Thunar thumbnail generation
}

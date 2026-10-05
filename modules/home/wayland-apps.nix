{ pkgs, ... }:
let
  # `screenshot --copy|--save|--swappy` — single CLI for the three
  # things you actually do with screenshots. Saves to
  # ~/Pictures/Screenshots/<ISO timestamp>.png on --save.
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date '+%Y-%m-%d_%H-%M-%S').png"

    case "$1" in
      --copy)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
        ;;
      --save)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$file"
        ;;
      --swappy)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
        ;;
      *)
        echo "Usage: screenshot [--copy|--save|--swappy]"
        exit 1
        ;;
    esac
  '';
in
{
  # Suppress tray applets that autostart via XDG — bluetooth/network are
  # handled by noctalia's bar widgets, so the applet icons would be duplicates.
  xdg.configFile."autostart/blueman.desktop".text = "[Desktop Entry]\nHidden=true\n";
  xdg.configFile."autostart/nm-applet.desktop".text = "[Desktop Entry]\nHidden=true\n";
  # Remmina writes this itself; its full-colour tray icon clashes with the
  # monochrome bar, and it is only ever opened on demand anyway.
  xdg.configFile."autostart/remmina-applet.desktop".text = "[Desktop Entry]\nHidden=true\n";

  # Wayland apps: tools spawned by niri binds and hardware-control utilities.
  # Bar, notifications, launcher, lock, idle and wallpaper come from noctalia.nix.

  home.packages = with pkgs; [
    screenshot
    grim
    slurp
    swappy
    wl-clipboard
    wl-clip-persist      # keep clipboard contents alive after source app exits
    brightnessctl
    pavucontrol
    playerctl
    networkmanagerapplet
    poweralertd          # low-battery desktop notifications
    hyprpolkitagent      # GUI polkit prompt agent (replaces lxqt-policykit)
  ];

  programs.kitty.enable = true;        # stylix themes it
}

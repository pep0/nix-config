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
  # Shared between Hyprland and niri: apps that compositor binds spawn
  # plus hardware-control utilities. Each compositor module adds its
  # own extras on top.

  home.packages = with pkgs; [
    screenshot
    grim
    slurp
    swappy            # annotation tool used by `screenshot --swappy`
    wl-clipboard
    brightnessctl
    pavucontrol
    pamixer
    playerctl
    networkmanagerapplet
  ];

  programs.kitty.enable = true;        # stylix themes it
  programs.waybar.enable = true;       # stylix themes it; systemd user service
  programs.fuzzel.enable = true;       # launcher; replaces wofi, stylix themes it
  programs.hyprlock.enable = true;     # lock screen; replaces swaylock

  # Notification daemon. Without one, `notify-send` and any Wayland app
  # sending notifications silently no-ops. Stylix themes mako too.
  services.mako.enable = true;

  # Idle daemon: lock → suspend. Compositor-agnostic, calls hyprlock.
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300;  command = "${pkgs.hyprlock}/bin/hyprlock"; }            # 5min: lock
      { timeout = 600;  command = "${pkgs.systemd}/bin/systemctl suspend"; }    # 10min: suspend
    ];
    # 26.05 changed events from list to attrset.
    events = {
      before-sleep = "${pkgs.hyprlock}/bin/hyprlock";
      lock         = "${pkgs.hyprlock}/bin/hyprlock";
    };
  };
}

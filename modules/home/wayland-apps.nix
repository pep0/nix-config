{ pkgs, ... }:
{
  # Shared between Hyprland and niri: the apps that compositor binds
  # spawn (terminal, launcher, status bar, screenshot, clipboard) plus
  # hardware-control utilities. swaylock + swayidle handle screen-lock
  # and idle behavior on both compositors.

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    brightnessctl
    pavucontrol
    pamixer
    playerctl
    networkmanagerapplet
    swaylock
  ];

  programs.kitty.enable = true;       # stylix themes it
  programs.waybar.enable = true;      # stylix themes it; provides systemd user service

  # Notification daemon. Without one, `notify-send` and any Wayland app
  # sending notifications silently no-ops. Stylix themes mako too.
  services.mako.enable = true;

  # Idle daemon: dim → lock → suspend. Times are minutes-to-trigger.
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300;  command = "${pkgs.swaylock}/bin/swaylock -f"; }       # 5min: lock
      { timeout = 600;  command = "${pkgs.systemd}/bin/systemctl suspend"; }  # 10min: suspend
    ];
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock";         command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
  };
}

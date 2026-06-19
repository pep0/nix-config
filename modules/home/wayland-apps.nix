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

  # `powermenu` — fuzzel-driven Lock/Logout/Suspend/Reboot/Shutdown
  # picker. Bound to Mod+P on both compositors.
  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    choice=$(printf "%s\n" \
      $'  Lock' \
      $'  Logout' \
      $'\U000f0904  Suspend' \
      $'  Reboot' \
      $'  Shutdown' \
      | ${pkgs.fuzzel}/bin/fuzzel --dmenu --hide-prompt --width 18 --lines 5)

    case "$choice" in
      *Lock)     ${pkgs.hyprlock}/bin/hyprlock ;;
      *Logout)   niri msg action quit ;;
      *Suspend)  systemctl suspend ;;
      *Reboot)   systemctl reboot ;;
      *Shutdown) systemctl poweroff ;;
    esac
  '';
in
{
  # Suppress tray applets that autostart via XDG — bluetooth/network are
  # handled by the waybar modules, so the applet icons would be duplicates.
  xdg.configFile."autostart/blueman.desktop".text = "[Desktop Entry]\nHidden=true\n";
  xdg.configFile."autostart/nm-applet.desktop".text = "[Desktop Entry]\nHidden=true\n";

  # Wayland apps: tools spawned by niri binds and hardware-control utilities.

  home.packages = with pkgs; [
    screenshot
    powermenu
    grim
    slurp
    swappy
    wl-clipboard
    wl-clip-persist      # keep clipboard contents alive after source app exits
    brightnessctl
    pavucontrol
    pamixer
    playerctl
    networkmanagerapplet
    poweralertd          # low-battery desktop notifications
    hyprpolkitagent      # GUI polkit prompt agent (replaces lxqt-policykit)
    swaybg               # wallpaper setter
  ];

  programs.kitty.enable = true;        # stylix themes it
  programs.waybar.enable = true;       # stylix themes it; systemd user service
  programs.fuzzel.enable = true;       # launcher; replaces wofi, stylix themes it
  programs.hyprlock.enable = true;     # lock screen; replaces swaylock

  # Notification daemon. Without one, `notify-send` and any Wayland app
  # sending notifications silently no-ops. Stylix themes mako too.
  services.mako.enable = true;

  # Idle daemon: lock → suspend. Compositor-agnostic, calls hyprlock.
  # -w: wait for the lock command to exit before resuming the idle counter,
  # preventing an immediate re-lock if the user takes >5min to unlock.
  services.swayidle = {
    enable = true;
    extraArgs = [ "-w" ];
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

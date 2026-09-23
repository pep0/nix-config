{ pkgs, ... }:
let
  # Used for all lock triggers (timeout, before-sleep, lock event, and the
  # Mod+Escape keybind in niri).
  #
  # flock guards against duplicate hyprlock instances: ext-session-lock-v1
  # allows only one locker at a time, and a queued second instance acquires
  # the lock the moment the first exits, causing an immediate re-lock. It
  # replaces a `pgrep -x hyprlock ||` test that never worked — swayidle.service
  # runs with a bash-only PATH, so pgrep was always "command not found".
  #
  # Detached on purpose: swayidle -w stops its event loop until the command
  # returns, so waiting on hyprlock itself parks every idle timeout that
  # elapses during the lock and delivers them all at unlock — which fired
  # `systemctl suspend` a second after typing the password. The sleep still
  # gives hyprlock time to cover the screen before a before-sleep suspend
  # proceeds.
  lock = pkgs.writeShellScriptBin "lock" ''
    ${pkgs.util-linux}/bin/flock -n "''${XDG_RUNTIME_DIR:-/tmp}/hyprlock.lock" \
      ${pkgs.hyprlock}/bin/hyprlock &
    ${pkgs.coreutils}/bin/sleep 0.5
  '';
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
      *Lock)     ${lock}/bin/lock ;;
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
  # Remmina writes this itself; its full-colour tray icon clashes with the
  # monochrome bar, and it is only ever opened on demand anyway.
  xdg.configFile."autostart/remmina-applet.desktop".text = "[Desktop Entry]\nHidden=true\n";

  # Wayland apps: tools spawned by niri binds and hardware-control utilities.

  home.packages = with pkgs; [
    screenshot
    powermenu
    lock
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
  programs.waybar.enable = true;       # stylix themes it; niri spawns it
  programs.fuzzel.enable = true;       # launcher; replaces wofi, stylix themes it
  programs.hyprlock.enable = true;     # lock screen; replaces swaylock

  # Notification daemon. Without one, `notify-send` and any Wayland app
  # sending notifications silently no-ops. Stylix themes mako too.
  services.mako.enable = true;

  # Idle daemon: lock → suspend. Compositor-agnostic, calls hyprlock.
  # -w: wait for each command to return, so the before-sleep lock has painted
  # before the system sleeps. Every command here must return promptly — see
  # the `lock` script above.
  services.swayidle = {
    enable = true;
    extraArgs = [ "-w" ];
    timeouts = [
      { timeout = 300;  command = "${lock}/bin/lock"; }
      { timeout = 600;  command = "${pkgs.systemd}/bin/systemctl suspend"; }
    ];
    # 26.05 changed events from list to attrset.
    events = {
      before-sleep = "${lock}/bin/lock";
      lock         = "${lock}/bin/lock";
    };
  };
}

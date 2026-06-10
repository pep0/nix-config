{ pkgs, ... }:
{
  # Waybar layout. Stylix's `targets.waybar` paints the colors; this
  # module owns layout + modules.

  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [
        "niri/workspaces"
      ];

      modules-center = [
        "niri/window"
      ];

      modules-right = [
        "tray"
        "bluetooth"
        "network"
        "pulseaudio"
        "backlight"
        "battery"
        "niri/language"
        "clock"
      ];

      "niri/workspaces" = {
        format = "{index}";
      };

      "niri/language" = {
        format = "󰌌 {short}";
      };

      "niri/window" = {
        format = "{title}";
        max-length = 60;
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      clock = {
        format = "{:%H:%M  %a %d}";
        format-alt = "{:%Y-%m-%d %H:%M:%S}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-alt = "{icon} {time}";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      backlight = {
        format = "󰃟 {percent}%";
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };

      network = {
        format-wifi = "󰤨 {signalStrength}%";
        format-ethernet = "󰈀 {ifname}";
        format-disconnected = "󰤭 offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%) via {gwaddr}";
        tooltip-format-ethernet = "{ifname} via {gwaddr}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };

      bluetooth = {
        format = "󰂲";
        format-disabled = "󰂲";
        format-off = "󰂲";
        format-connected = "󰂯 {num_connections}";
        tooltip-format = "{controller_alias}  {controller_address}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}  {device_address}";
        on-click = "${pkgs.blueman}/bin/blueman-manager";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-bluetooth = "󰂯 {icon} {volume}%";
        format-muted = "󰖁";
        format-icons = {
          headphone = "󰋋";
          hands-free = "󰋎";
          headset = "󰋎";
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.pamixer}/bin/pamixer -t";
        scroll-step = 5;
      };
    };
  };
}

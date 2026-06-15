{ pkgs, config, ... }:
let
  c = name: "#${config.lib.stylix.colors.${name}}";
in
{
  programs.waybar = {
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "cpu"
        "memory"
        "pulseaudio"
        "backlight"
        "network"
        "bluetooth"
        "battery"
        "niri/language"
      ];

      "niri/workspaces".format = "{index}";

      "niri/language".format = "󰌌 {short}";

      tray = { icon-size = 16; spacing = 8; };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%d/%m/%Y}";
        tooltip = true;
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = "󰻠 {usage}%";
        tooltip = false;
        on-click = "kitty -e btop";
      };

      memory = {
        format = "󰍛 {used:0.1f}G";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        on-click = "kitty -e btop";
      };

      battery = {
        states = { warning = 30; critical = 15; };
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
        format-connected = "󰂯 {num_connections}";
        format-disabled = "󰂲";
        format-off = "󰂲";
        tooltip-format = "{controller_alias}  {controller_address}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}  {device_address}";
        on-click = "${pkgs.blueman}/bin/blueman-manager";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}%";
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

    style = ''
      window#waybar, window#waybar * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 10pt;
      }

      /* Spacing between right-side modules */
      #cpu, #memory, #pulseaudio, #backlight,
      #network, #bluetooth, #battery, #language, #clock, #tray {
        margin: 0 6px;
      }

      /* Override stylix's border-bottom on workspace buttons */
      .modules-left #workspaces button,
      .modules-left #workspaces button.focused,
      .modules-left #workspaces button.active {
        border-bottom: none;
      }

      #workspaces button {
        color: ${c "base03"};
        background: transparent;
        padding: 0 8px;
        border: none;
        min-width: 24px;
      }

      #workspaces button.active {
        color: ${c "base0A"};
      }

      #workspaces button.urgent {
        color: ${c "base08"};
      }

      #workspaces button:hover {
        color: ${c "base05"};
        background: ${c "base01"};
      }

      #battery.warning {
        color: ${c "base09"};
      }

      #battery.critical {
        color: ${c "base08"};
      }
    '';
  };
}

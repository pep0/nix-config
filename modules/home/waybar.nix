{ pkgs, ... }:
{
  # Waybar layout. Stylix's `targets.waybar` paints the colors; this
  # module owns layout + modules. Both Hyprland and niri workspace
  # modules are listed — waybar auto-shows the one whose IPC is live.

  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [
        "hyprland/workspaces"
        "niri/workspaces"
      ];

      modules-center = [
        "hyprland/window"
        "niri/window"
      ];

      modules-right = [
        "tray"
        "bluetooth"
        "network"
        "pulseaudio"
        "backlight"
        "battery"
        "clock"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          active = "●";
          default = "○";
          urgent = "!";
        };
        on-click = "activate";
      };

      "niri/workspaces" = {
        format = "{index}";
      };

      "hyprland/window" = {
        format = "{title}";
        max-length = 60;
        separate-outputs = true;
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
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-icons = [ "" "" "" "" "" ];
      };

      backlight = {
        format = "{percent}% {icon}";
        format-icons = [ "" "" "" "" "" "" "" "" "" ];
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };

      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname} ";
        format-disconnected = "disconnected ⚠";
        tooltip-format = "{ifname} via {gwaddr}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };

      bluetooth = {
        format = "";
        format-disabled = "";
        format-off = "";
        format-connected = " {num_connections}";
        tooltip-format = "{controller_alias}\t{controller_address}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        on-click = "${pkgs.blueman}/bin/blueman-manager";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon} ";
        format-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          default = [ "" "" "" ];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.pamixer}/bin/pamixer -t";
        scroll-step = 5;
      };
    };
  };
}

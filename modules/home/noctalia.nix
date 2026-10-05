{ config, inputs, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    # Started by graphical-session.target, which niri's session brings up.
    systemd.enable = true;

    # Stylix's own noctalia target only supports v4, so map base16 by hand.
    customPalettes.stylix.dark = with colors; {
      mPrimary = base0D;
      mOnPrimary = base00;
      mSecondary = base0E;
      mOnSecondary = base00;
      mTertiary = base0C;
      mOnTertiary = base00;
      mError = base08;
      mOnError = base00;
      mSurface = base00;
      mOnSurface = base05;
      mSurfaceVariant = base01;
      mOnSurfaceVariant = base04;
      mOutline = base03;
      mShadow = base00;
      mHover = base0C;
      mOnHover = base00;
      # Without it the palette is silently rejected and the builtin one is used.
      terminal = {
        background = base00;
        foreground = base05;
        cursor = base05;
        cursorText = base00;
        selectionBg = base02;
        selectionFg = base05;
        normal = {
          black = base00;
          red = base08;
          green = base0B;
          yellow = base0A;
          blue = base0D;
          magenta = base0E;
          cyan = base0C;
          white = base05;
        };
        bright = {
          black = base03;
          red = base08;
          green = base0B;
          yellow = base0A;
          blue = base0D;
          magenta = base0E;
          cyan = base0C;
          white = base07;
        };
      };
    };

    settings = {
      shell = {
        font_family = config.stylix.fonts.sansSerif.name;
        # Restarting the shell then doesn't take launched apps down with it.
        launch_apps_as_systemd_services = true;
        # wl-clip-persist already does this.
        clipboard_keep_from_closed_apps = false;
      };

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "stylix";
      };

      wallpaper = {
        enabled = true;
        default.path = "${config.stylix.image}";
      };

      # Locks before suspending (lockscreen.lock_before_suspend defaults on).
      idle.behavior = {
        lock = {
          timeout = 300;
          action = "lock";
          enabled = true;
        };
        suspend = {
          timeout = 600;
          action = "suspend";
          enabled = true;
        };
      };

      widget = {
        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
        };
        ram = {
          type = "sysmon";
          stat = "ram_used";
        };
        network.show_label = false;
      };

      bar.main =
        let
          group = id: members: {
            inherit id members;
            fill = "surface_variant";
            padding = 8.0;
            widget_spacing = 10;
          };
        in
        {
          widget_spacing = 10;
          start = [
            "launcher"
            "workspaces"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "group:sys"
            "group:media"
            "group:status"
            "group:shell"
          ];
          capsule_group = [
            (group "sys" [ "cpu" "ram" ])
            (group "media" [ "volume" "brightness" ])
            (group "status" [ "network" "bluetooth" "battery" "keyboard_layout" ])
            (group "shell" [ "notifications" "control-center" "session" ])
          ];
        };
    };
  };
}

# Waybar Module
# Modern Tokyo Night themed status bar with Android-inspired UI
{
  config,
  pkgs,
  lib,
  pkgsUnstable,
  ...
}: let
  cfg = config.myModules.waybar;

  # Tokyo Night color palette
  colors = {
    bg = "1a1b26";
    bg_dark = "16161e";
    bg_highlight = "292e42";
    bg_status = "24283b";
    fg = "c0caf5";
    fg_dark = "a9b1d6";
    fg_gutter = "3b4261";
    black = "15161e";
    red = "f7768e";
    green = "9ece6a";
    yellow = "e0af68";
    blue = "7aa2f7";
    magenta = "bb9af7";
    cyan = "7dcfff";
    white = "a9b1d6";
    orange = "ff9e64";
    pink = "ff007c";
    purple = "9d7cd8";
    teal = "1abc9c";
  };
in {
  options.myModules.waybar = {
    enable = lib.mkEnableOption "Waybar status bar";

    position = lib.mkOption {
      type = lib.types.enum ["top" "bottom"];
      default = "top";
      description = "Position of the waybar";
    };

    height = lib.mkOption {
      type = lib.types.int;
      default = 44;
      description = "Height of the waybar in pixels";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgsUnstable.waybar;
      systemd.enable = false;

      settings = {
        mainBar = {
          layer = "top";
          position = cfg.position;
          height = cfg.height;
          margin = "8 12 0 12";
          spacing = 8;

          modules-left = [
            "custom/logo"
            "hyprland/workspaces"
            "hyprland/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "tray"
            "idle_inhibitor"
            "custom/notification"
            "group/hardware"
            "group/audio"
            "group/network"
            "battery"
            "custom/power"
          ];

          "custom/logo" = {
            format = "";
            tooltip = false;
            on-click = "rofi -show drun";
          };

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "10";
              default = "";
              active = "";
              urgent = "";
            };
          };

          "hyprland/window" = {
            format = "{title}";
            max-length = 40;
            separate-outputs = true;
            tooltip = false;
            rewrite = {
              "(.*) — Mozilla Firefox" = "󰈹 $1";
              "(.*) - Brave" = "󰖟 $1";
              "(.*) - Visual Studio Code" = "󰨞 $1";
              "(.*) - zsh" = "󰆍 $1";
              "(.*) - fish" = "󰆍 $1";
            };
          };

          clock = {
            format = "󰸗 {:%a %b %d  󰥔 %H:%M}";
            format-alt = "󰥔 {:%H:%M:%S}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}";
            calendar = {
              mode = "month";
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#${colors.fg}'><b>{}</b></span>";
                days = "<span color='#${colors.fg_dark}'><b>{}</b></span>";
                weeks = "<span color='#${colors.blue}'><b>W{}</b></span>";
                weekdays = "<span color='#${colors.orange}'><b>{}</b></span>";
                today = "<span color='#${colors.red}'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click = "mode";
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          "group/hardware" = {
            orientation = "horizontal";
            modules = [
              "cpu"
              "memory"
              "temperature"
              "disk"
            ];
            drawer = {
              transition-duration = 300;
              children-class = "hardware-child";
              transition-left-to-right = true;
            };
          };

          "group/audio" = {
            orientation = "horizontal";
            modules = [
              "pulseaudio"
              "pulseaudio#microphone"
            ];
            drawer = {
              transition-duration = 300;
              children-class = "audio-child";
              transition-left-to-right = true;
            };
          };

          "group/network" = {
            orientation = "horizontal";
            modules = [
              "network"
              "bluetooth"
            ];
            drawer = {
              transition-duration = 300;
              children-class = "network-child";
              transition-left-to-right = true;
            };
          };

          cpu = {
            format = "󰍛 {usage}%";
            format-alt = "󰍛 {avg_frequency} GHz";
            tooltip = true;
            tooltip-format = "CPU: {usage}%\nLoad: {load}\nTemp: {temperatureC}°C";
            interval = 2;
            on-click = "kitty btop";
            states = {
              low = 0;
              moderate = 50;
              high = 80;
            };
          };

          memory = {
            format = "󰘚 {}%";
            format-alt = "󰘚 {used:0.1f}G";
            tooltip = true;
            tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G";
            interval = 5;
            on-click = "kitty btop";
          };

          temperature = {
            critical-threshold = 80;
            format = "󰔏 {temperatureC}°C";
            format-critical = "󰸁 {temperatureC}°C";
            tooltip = true;
            interval = 5;
          };

          disk = {
            format = "󰋊 {percentage_used}%";
            format-alt = "󰋊 {used}/{total}";
            tooltip = true;
            tooltip-format = "{used} used of {total} ({percentage_used}%)";
            path = "/";
            interval = 60;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰖁 Muted";
            format-bluetooth = "󰂯 {volume}%";
            format-bluetooth-muted = "󰂯 Muted";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󰥰";
              headset = "󰋎";
              phone = "󰏲";
              portable = "󰏲";
              car = "󰄋";
              default = ["󰕿" "󰖀" "󰕾"];
            };
            scroll-step = 2;
            on-click = "pavucontrol";
            on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            tooltip = true;
            tooltip-format = "{desc}\nVolume: {volume}%";
          };

          "pulseaudio#microphone" = {
            format = "{icon}";
            format-muted = "󰍭";
            format-icons = {
              default = ["󰍬" "󰍬"];
            };
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            on-click-right = "pavucontrol";
            tooltip = true;
            tooltip-format = "{desc}\nVolume: {volume}%";
          };

          network = {
            format-wifi = "󰤨 {essid}";
            format-wifi-alt = "󰤨 {signalStrength}%";
            format-ethernet = "󰈀 {ipaddr}";
            format-linked = "󰈀 {ifname} (No IP)";
            format-disconnected = "󰤭 Offline";
            format-disabled = "󰤭 Disabled";
            tooltip = true;
            tooltip-format = "Interface: {ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}\nSpeed: ↓{bandwidthDownBits} ↑{bandwidthUpBits}";
            on-click = "nm-connection-editor";
            on-click-right = "kitty nmtui";
            interval = 5;
          };

          bluetooth = {
            format = "󰂯";
            format-disabled = "󰂲";
            format-connected = "󰂱 {num_connections}";
            format-connected-battery = "󰂱 {num_connections} 󰥉 {device_battery_percentage}%";
            tooltip = true;
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "blueman-manager";
          };

          battery = {
            states = {
              excellent = 95;
              good = 80;
              okay = 50;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            tooltip = true;
            tooltip-format = "{timeTo}\n{power}W draw";
            interval = 5;
          };

          tray = {
            icon-size = 18;
            spacing = 8;
            show-passive-items = true;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰛊";
              deactivated = "󰾪";
            };
            tooltip = true;
            tooltip-format-activated = "Idle inhibitor: ON";
            tooltip-format-deactivated = "Idle inhibitor: OFF";
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "󰂚<span foreground='#${colors.red}'> </span>";
              none = "󰂚";
              dnd-notification = "󰂛<span foreground='#${colors.red}'> </span>";
              dnd-none = "󰂛";
              inhibited-notification = "󰂚<span foreground='#${colors.red}'> </span>";
              inhibited-none = "󰂚";
              dnd-inhibited-notification = "󰂛<span foreground='#${colors.red}'> </span>";
              dnd-inhibited-none = "󰂛";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -d -sw";
            escape = true;
            interval = 3;
          };

          "custom/power" = {
            format = "";
            tooltip = false;
            on-click = "wlogout";
          };
        };
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
          font-size: 13px;
          font-weight: 600;
          min-height: 0;
          padding: 0;
          margin: 0;
          border: none;
          border-radius: 0;
        }

        window#waybar {
          background-color: transparent;
          color: #${colors.fg};
        }

        window#waybar > box {
          background: rgba(26, 27, 38, 0.85);
          border-radius: 16px;
          margin: 8px 12px 0 12px;
          padding: 4px 12px;
          box-shadow:
            0 4px 6px -1px rgba(0, 0, 0, 0.3),
            0 2px 4px -1px rgba(0, 0, 0, 0.2),
            inset 0 1px 0 rgba(255, 255, 255, 0.05);
          border: 1px solid rgba(122, 162, 247, 0.15);
        }

        #workspaces {
          background: rgba(41, 46, 66, 0.5);
          border-radius: 12px;
          padding: 4px 6px;
          margin: 4px 0;
        }

        #workspaces button {
          padding: 0 12px;
          margin: 0 2px;
          color: #${colors.fg_dark};
          background: transparent;
          border-radius: 8px;
          transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
          min-width: 24px;
        }

        #workspaces button:hover {
          background: rgba(122, 162, 247, 0.2);
          color: #${colors.fg};
        }

        #workspaces button.active {
          background: linear-gradient(135deg, #${colors.blue}, #${colors.purple});
          color: #${colors.bg};
          box-shadow: 0 2px 8px rgba(122, 162, 247, 0.4);
        }

        #workspaces button.urgent {
          background: linear-gradient(135deg, #${colors.red}, #${colors.orange});
          color: #${colors.bg};
        }

        #window {
          color: #${colors.fg_dark};
          padding: 0 16px;
          font-weight: 500;
        }

        #custom-logo {
          color: #${colors.blue};
          font-size: 20px;
          padding: 0 12px 0 4px;
          margin-right: 4px;
          transition: all 0.2s ease;
        }

        #custom-logo:hover {
          color: #${colors.cyan};
          text-shadow: 0 0 10px rgba(125, 207, 255, 0.5);
        }

        #clock {
          background: linear-gradient(135deg, rgba(122, 162, 247, 0.15), rgba(187, 154, 247, 0.15));
          color: #${colors.fg};
          padding: 6px 16px;
          border-radius: 12px;
          font-weight: 600;
          border: 1px solid rgba(122, 162, 247, 0.2);
        }

        #clock:hover {
          background: linear-gradient(135deg, rgba(122, 162, 247, 0.25), rgba(187, 154, 247, 0.25));
        }

        .modules-right {
          padding: 0;
        }

        #group-hardware,
        #group-audio,
        #group-network {
          background: rgba(41, 46, 66, 0.5);
          border-radius: 12px;
          padding: 4px 6px;
          margin: 0 4px;
        }

        #cpu {
          color: #${colors.blue};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #cpu:hover {
          background: rgba(122, 162, 247, 0.15);
        }

        #cpu.high {
          color: #${colors.red};
        }

        #memory {
          color: #${colors.purple};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #memory:hover {
          background: rgba(187, 154, 247, 0.15);
        }

        #temperature {
          color: #${colors.orange};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #temperature.critical {
          color: #${colors.red};
          background: rgba(247, 118, 142, 0.2);
        }

        #disk {
          color: #${colors.cyan};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #pulseaudio {
          color: #${colors.green};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #pulseaudio:hover {
          background: rgba(158, 206, 106, 0.15);
        }

        #pulseaudio.muted {
          color: #${colors.fg_gutter};
        }

        #pulseaudio.microphone {
          color: #${colors.teal};
          padding: 4px 8px;
        }

        #network {
          color: #${colors.blue};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #network:hover {
          background: rgba(122, 162, 247, 0.15);
        }

        #network.disconnected,
        #network.disabled {
          color: #${colors.fg_gutter};
        }

        #network.wifi {
          color: #${colors.cyan};
        }

        #bluetooth {
          color: #${colors.blue};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #bluetooth:hover {
          background: rgba(122, 162, 247, 0.15);
        }

        #bluetooth.disabled {
          color: #${colors.fg_gutter};
        }

        #bluetooth.connected {
          color: #${colors.cyan};
        }

        #battery {
          padding: 4px 12px;
          border-radius: 12px;
          margin: 0 4px;
          transition: all 0.3s ease;
        }

        #battery.excellent,
        #battery.good {
          color: #${colors.green};
          background: rgba(158, 206, 106, 0.1);
        }

        #battery.okay {
          color: #${colors.yellow};
          background: rgba(224, 175, 104, 0.1);
        }

        #battery.warning {
          color: #${colors.orange};
          background: rgba(255, 158, 100, 0.15);
        }

        #battery.critical {
          color: #${colors.red};
          background: rgba(247, 118, 142, 0.2);
        }

        #battery.charging,
        #battery.plugged {
          color: #${colors.green};
          background: rgba(158, 206, 106, 0.2);
        }

        #tray {
          background: rgba(41, 46, 66, 0.5);
          border-radius: 12px;
          padding: 4px 10px;
          margin: 0 4px;
        }



        #idle_inhibitor {
          color: #${colors.fg_gutter};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #idle_inhibitor.activated {
          color: #${colors.yellow};
          background: rgba(224, 175, 104, 0.15);
        }

        #idle_inhibitor:hover {
          background: rgba(224, 175, 104, 0.1);
        }

        #custom-notification {
          color: #${colors.fg_dark};
          padding: 4px 10px;
          border-radius: 8px;
          transition: all 0.2s ease;
        }

        #custom-notification.notification {
          color: #${colors.blue};
          background: rgba(122, 162, 247, 0.15);
        }

        #custom-notification.dnd {
          color: #${colors.orange};
        }

        #custom-power {
          color: #${colors.red};
          font-size: 16px;
          padding: 4px 12px;
          margin-left: 4px;
          border-radius: 10px;
          background: rgba(247, 118, 142, 0.1);
          transition: all 0.2s ease;
        }

        #custom-power:hover {
          background: rgba(247, 118, 142, 0.25);
          box-shadow: 0 0 15px rgba(247, 118, 142, 0.3);
        }

        tooltip {
          background: rgba(22, 22, 30, 0.95);
          border-radius: 12px;
          border: 1px solid rgba(122, 162, 247, 0.2);
          padding: 12px;
          box-shadow:
            0 10px 15px -3px rgba(0, 0, 0, 0.4),
            0 4px 6px -2px rgba(0, 0, 0, 0.2);
        }

        tooltip label {
          color: #${colors.fg};
          font-size: 12px;
          padding: 4px 8px;
        }

        .hardware-child,
        .audio-child,
        .network-child {
          opacity: 0.8;
          transition: opacity 0.2s ease;
        }

        .hardware-child:hover,
        .audio-child:hover,
        .network-child:hover {
          opacity: 1;
        }

        #group-hardware:hover,
        #group-audio:hover,
        #group-network:hover {
          background: rgba(41, 46, 66, 0.7);
        }
      '';
    };

    home.packages = with pkgs; [
      btop
      lm_sensors
      pavucontrol
      wireplumber
      networkmanagerapplet
      blueman
      swaynotificationcenter
      wlogout
      playerctl
    ];

    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-margin-top = 10;
        control-center-margin-bottom = 10;
        control-center-margin-right = 10;
        control-center-margin-left = 10;
        notification-icon-size = 48;
        notification-body-image-height = 160;
        notification-body-image-width = 200;
        timeout = 8;
        timeout-low = 4;
        timeout-critical = 0;
        fit-to-screen = true;
        control-center-width = 380;
        notification-window-width = 360;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 200;
        hide-on-clear = true;
        hide-on-action = true;
        script-fail-notify = true;
        widgets = [
          "title"
          "notifications"
          "mpris"
          "volume"
          "dnd"
        ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
          mpris = {
            image-size = 96;
            image-radius = 12;
          };
          volume = {
            label = "󰕾";
          };
        };
      };
      style = ''
        @define-color cc-bg rgba(26, 27, 38, 0.95);
        @define-color noti-border-color rgba(122, 162, 247, 0.3);
        @define-color noti-bg rgba(22, 22, 30, 0.95);
        @define-color noti-bg-hover rgba(41, 46, 66, 0.9);
        @define-color noti-bg-focus rgba(41, 46, 66, 0.9);
        @define-color text-color #c0caf5;
        @define-color text-color-disabled #565f89;
        @define-color bg-selected #7aa2f7;

        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
        }

        .notification-row {
          outline: none;
        }

        .notification-row:focus,
        .notification-row:hover {
          background: @noti-bg-focus;
        }

        .notification {
          border-radius: 16px;
          margin: 8px 12px;
          padding: 0;
          border: 1px solid @noti-border-color;
          background: @noti-bg;
        }

        .notification-content {
          padding: 16px;
        }

        .close-button {
          background: rgba(247, 118, 142, 0.2);
          color: #f7768e;
          text-shadow: none;
          padding: 0;
          border-radius: 100%;
          margin-top: 8px;
          margin-right: 8px;
          box-shadow: none;
          border: none;
          min-width: 24px;
          min-height: 24px;
        }

        .close-button:hover {
          box-shadow: none;
          background: rgba(247, 118, 142, 0.4);
          transition: all 0.15s ease-in-out;
        }

        .notification-default-action,
        .notification-action {
          padding: 4px;
          margin: 0;
          box-shadow: none;
          background: transparent;
          border: none;
          color: @text-color;
          transition: all 0.15s ease-in-out;
        }

        .notification-default-action:hover,
        .notification-action:hover {
          background: @noti-bg-hover;
        }

        .notification-default-action {
          border-radius: 16px;
        }

        .notification-default-action:not(:only-child) {
          border-bottom-left-radius: 0;
          border-bottom-right-radius: 0;
        }

        .notification-action {
          border-radius: 0;
          border-top: 1px solid @noti-border-color;
        }

        .notification-action:first-child {
          border-bottom-left-radius: 16px;
        }

        .notification-action:last-child {
          border-bottom-right-radius: 16px;
        }

        .inline-reply {
          margin-top: 8px;
        }

        .inline-reply-entry {
          background: @noti-bg-hover;
          color: @text-color;
          caret-color: @text-color;
          border: 1px solid @noti-border-color;
          border-radius: 12px;
        }

        .inline-reply-button {
          margin-left: 4px;
          background: @noti-bg;
          border: 1px solid @noti-border-color;
          border-radius: 12px;
          color: @text-color;
        }

        .inline-reply-button:disabled {
          background: initial;
          color: @text-color-disabled;
          border: 1px solid transparent;
        }

        .inline-reply-button:hover {
          background: @noti-bg-hover;
        }

        .body-image {
          margin-top: 6px;
          background-color: transparent;
          border-radius: 12px;
        }

        .summary {
          font-size: 14px;
          font-weight: bold;
          background: transparent;
          color: @text-color;
          text-shadow: none;
        }

        .time {
          font-size: 11px;
          font-weight: normal;
          background: transparent;
          color: @text-color-disabled;
          text-shadow: none;
          margin-right: 18px;
        }

        .body {
          font-size: 12px;
          font-weight: normal;
          background: transparent;
          color: @text-color;
          text-shadow: none;
        }

        .control-center {
          background: @cc-bg;
          border: 1px solid @noti-border-color;
          border-radius: 24px;
          padding: 16px;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .control-center-list {
          background: transparent;
        }

        .control-center-list-placeholder {
          opacity: 0.5;
        }

        .floating-notifications {
          background: transparent;
        }

        .blank-window {
          background: transparent;
        }

        .widget-title {
          color: @text-color;
          margin: 8px;
          font-size: 16px;
          font-weight: bold;
        }

        .widget-title > button {
          font-size: 12px;
          font-weight: normal;
          color: @text-color;
          text-shadow: none;
          background: @noti-bg;
          border: 1px solid @noti-border-color;
          box-shadow: none;
          border-radius: 12px;
          padding: 6px 12px;
        }

        .widget-title > button:hover {
          background: @noti-bg-hover;
        }

        .widget-dnd {
          color: @text-color;
          margin: 8px;
          font-size: 12px;
        }

        .widget-dnd > switch {
          font-size: initial;
          border-radius: 100px;
          background: @noti-bg;
          border: 1px solid @noti-border-color;
          box-shadow: none;
        }

        .widget-dnd > switch:checked {
          background: @bg-selected;
        }

        .widget-dnd > switch slider {
          background: @text-color;
          border-radius: 100px;
        }

        .widget-dnd > switch:checked slider {
          background: @cc-bg;
        }

        .widget-mpris {
          background: @noti-bg;
          padding: 16px;
          margin: 8px;
          border-radius: 16px;
          border: 1px solid @noti-border-color;
        }

        .widget-mpris > box > button {
          border-radius: 12px;
        }

        .widget-mpris-player {
          padding: 12px;
          margin: 8px;
        }

        .widget-mpris-title {
          font-weight: bold;
          font-size: 14px;
        }

        .widget-mpris-subtitle {
          font-size: 12px;
          color: @text-color-disabled;
        }

        .widget-mpris > box > button {
          border: none;
          background: transparent;
          color: @text-color;
          padding: 8px;
          margin: 0 4px;
        }

        .widget-mpris > box > button:hover {
          background: @noti-bg-hover;
          border-radius: 12px;
        }

        .widget-volume {
          background: @noti-bg;
          padding: 12px;
          margin: 8px;
          border-radius: 16px;
          border: 1px solid @noti-border-color;
        }

        .widget-volume > box > button {
          background: transparent;
          border: none;
        }

        .per-app-volume {
          background: transparent;
          padding: 8px;
          margin: 0;
          border-radius: 12px;
        }

        .per-app-volume > row {
          background: @noti-bg-hover;
          border-radius: 8px;
          margin: 4px 0;
          padding: 4px 8px;
        }
      '';
    };

    home.file.".config/wlogout/layout".text = ''
      {
          "label" : "lock",
          "action" : "hyprlock",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "logout",
          "action" : "hyprctl dispatch exit",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Restart",
          "keybind" : "r"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Power Off",
          "keybind" : "s"
      }
    '';

    home.file.".config/wlogout/style.css".text = ''
      * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        background-color: rgba(22, 22, 30, 0.95);
      }

      button {
        color: #c0caf5;
        background-color: rgba(26, 27, 38, 0.8);
        border: 1px solid rgba(122, 162, 247, 0.2);
        border-radius: 20px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        margin: 10px;
        padding: 20px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
        transition: all 0.2s ease;
      }

      button:hover {
        background-color: rgba(41, 46, 66, 0.9);
        border-color: rgba(122, 162, 247, 0.4);
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 0 20px rgba(122, 162, 247, 0.2);
        transform: translateY(-2px);
      }

      button:focus {
        background-color: rgba(122, 162, 247, 0.2);
        border-color: #7aa2f7;
      }

      #lock {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"), url("/usr/share/wlogout/icons/lock.png"));
      }

      #logout {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"), url("/usr/share/wlogout/icons/logout.png"));
      }

      #suspend {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"), url("/usr/share/wlogout/icons/suspend.png"));
      }

      #reboot {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"), url("/usr/share/wlogout/icons/reboot.png"));
      }

      #shutdown {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"), url("/usr/share/wlogout/icons/shutdown.png"));
      }
    '';
  };
}

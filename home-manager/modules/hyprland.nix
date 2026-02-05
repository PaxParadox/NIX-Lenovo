# Hyprland Configuration Module
#
# Modern Wayland compositor configuration with all essential utilities
# for a complete desktop experience.

{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:

with lib;

let
  cfg = config.myModules.hyprland;
in {
  options.myModules.hyprland = {
    enable = mkEnableOption "Hyprland window manager with modern utilities";

    wallpaper = mkOption {
      type = types.path;
      default = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath}";
      description = "Default wallpaper path";
    };

    monitor = mkOption {
      type = types.str;
      default = ",preferred,auto,auto";
      description = "Monitor configuration (see Hyprland wiki for format)";
    };
  };

  config = mkIf cfg.enable {
    # Hyprland packages - mix of unstable (latest Hyprland tools) and stable
    home.packages =
      (with pkgsUnstable; [
        # Core Hyprland utilities (latest from unstable)
        waybar # Status bar
        rofi # Application launcher (includes Wayland support)
        wlogout # Power menu
        hyprlock # Screen locker (native to Hyprland)
        hypridle # Idle management
        mako # Notification daemon
        wl-clipboard # Clipboard management
        wl-clip-persist # Persistent clipboard
        grimblast # Screenshot utility
        satty # Screenshot annotation
        swww # Animated wallpaper daemon
        wev # Wayland event viewer
        wlr-randr # Display configuration
        wtype # xdotool for wayland
      ])
      ++ (with pkgs; [
        # Standard utilities (from stable)
        libnotify # notify-send commands
        networkmanagerapplet # Network tray icon (note: no hyphen in nixpkgs)
        blueman # Bluetooth tray icon
        pavucontrol # PulseAudio volume control GUI
        brightnessctl # Screen brightness
        playerctl # Media player control
        nwg-look # GTK theme switcher for Wayland
        libsForQt5.qt5ct # Qt5 theme configuration
        kdePackages.qt6ct # Qt6 theme configuration
        papirus-icon-theme # Modern icon theme
        nautilus # GNOME Files
      ]);

    # Enable Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgsUnstable.hyprland;
      xwayland.enable = true;

      # Use home-manager to manage the config file
      extraConfig = ''
        # Monitor configuration
        monitor=${cfg.monitor}

        # Input configuration
        input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1
          sensitivity = 0

          touchpad {
            natural_scroll = true
          }
        }

        # Gestures configuration
        # 3-finger horizontal swipes for workspace switching
        # Using dispatcher action for explicit workspace switching
        gesture = 3, left, dispatcher, workspace, +1
        gesture = 3, right, dispatcher, workspace, -1

        # General settings
        general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
          layout = dwindle
          resize_on_border = true
        }

        # Decoration settings
        decoration {
          rounding = 10
          blur {
            enabled = true
            size = 3
            passes = 1
          }
          shadow {
            enabled = true
            range = 4
            render_power = 3
            color = rgba(1a1a1aee)
          }
        }

        # Animation settings
        animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
        }

        # Layout settings
        dwindle {
          pseudotile = true
          preserve_split = true
        }

        master {
          new_status = master
        }

        # Misc settings
        misc {
          force_default_wallpaper = -1
          disable_hyprland_logo = false
        }

        # Window rules - new v0.53+ syntax
        rule = match:class:^(imv)$, float:true
        rule = match:class:^(mpv)$, float:true
        rule = match:class:^(ghostty)$, opacity:0.9 0.9
        rule = match:class:^(code)$, opacity:0.95 0.95

        # Layerrules for blur - v0.53+ block syntax
        layerrule {
          name = waybar_blur
          match:namespace = ^(waybar)$
          blur = true
        }
        layerrule {
          name = rofi_blur
          match:namespace = ^(rofi)$
          blur = true
        }
        layerrule {
          name = notifications_blur
          match:namespace = ^(notifications)$
          blur = true
        }

        # Autostart applications
        exec-once = swww init
        exec-once = waybar
        exec-once = mako
        exec-once = nm-applet --indicator
        exec-once = blueman-applet
        exec-once = ${pkgsUnstable.hypridle}/bin/hypridle
        exec-once = ${pkgs.bash}/bin/bash -c 'sleep 1 && swww img ${cfg.wallpaper}'

        # Key bindings
        $mainMod = SUPER

        # Basic window management
        bind = $mainMod, Return, exec, ghostty
        bind = $mainMod, Q, killactive,
        bind = $mainMod, M, exit,
        bind = $mainMod, V, togglefloating,
        bind = $mainMod, R, exec, rofi -show drun -show-icons
        bind = $mainMod, P, pseudo,
        bind = $mainMod, J, togglesplit,
        bind = $mainMod, F, fullscreen,

        # Lock screen
        bind = $mainMod, L, exec, hyprlock

        # Power menu
        bind = $mainMod SHIFT, E, exec, wlogout

        # Screenshot
        bind = , Print, exec, grimblast --notify copy area
        bind = SHIFT, Print, exec, grimblast --notify save area ~/Pictures/Screenshots/$(date +%Y-%m-%d-%H-%M-%S).png
        bind = CTRL, Print, exec, grimblast --notify copy screen

        # Focus movement
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        # Window movement
        bind = $mainMod SHIFT, left, movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r
        bind = $mainMod SHIFT, up, movewindow, u
        bind = $mainMod SHIFT, down, movewindow, d

        # Workspace switching
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10

        # Move window to workspace
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Scroll through workspaces
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        # Mouse bindings
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # Media keys
        bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bindel = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        bindel = , XF86MonBrightnessUp, exec, brightnessctl set +5%
        bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

        # Media control
        bindl = , XF86AudioNext, exec, playerctl next
        bindl = , XF86AudioPause, exec, playerctl play-pause
        bindl = , XF86AudioPlay, exec, playerctl play-pause
        bindl = , XF86AudioPrev, exec, playerctl previous
      '';
    };

    # Hyprlock configuration
    programs.hyprlock = {
      enable = true;
      package = pkgsUnstable.hyprlock;

      settings = {
        background = {
          path = toString cfg.wallpaper;
          blur_passes = 3;
          blur_size = 8;
        };

        general = {
          grace = 0;
          hide_cursor = true;
          no_fade_in = false;
        };

        input-field = {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.35;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          placeholder_text = ''<span foreground="##cdd6f4">Password...</span>'';
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
        };

        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 120;
            position = "0, 300";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
            font_size = 40;
            position = "0, 180";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    # Hypridle configuration
    services.hypridle = {
      enable = true;
      package = pkgsUnstable.hypridle;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 600;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 900;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    # Waybar configuration
    programs.waybar = {
      enable = true;
      package = pkgsUnstable.waybar;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 4;
          margin-top = 6;
          margin-left = 6;
          margin-right = 6;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "tray" "network" "bluetooth" "pulseaudio" "backlight" "battery" "custom/power" ];

          "hyprland/workspaces" = {
            format = "{name}";
            on-click = "activate";
            sort-by-number = true;
          };

          "hyprland/window" = {
            max-length = 50;
            separate-outputs = true;
          };

          clock = {
            format = "{:%Y-%m-%d %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}";
            format-alt = "{:%H:%M}";
          };

          tray = {
            icon-size = 18;
            spacing = 10;
          };

          network = {
            format-wifi = "󰤨  {signalStrength}%";
            format-ethernet = "󰈀  {ipaddr}";
            format-disconnected = "󰤭  Offline";
            tooltip-format = "{essid}";
            on-click = "nm-connection-editor";
          };

          bluetooth = {
            format = "󰂯  {status}";
            format-connected = "󰂱  {device_alias}";
            format-connected-battery = "󰂱  {device_alias} {device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "blueman-manager";
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            format-muted = "󰖁  Muted";
            format-icons = {
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            on-click = "pavucontrol";
          };

          backlight = {
            format = "󰃝  {percent}%";
            on-scroll-up = "brightnessctl set +5%";
            on-scroll-down = "brightnessctl set 5%-";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon}  {capacity}%";
            format-charging = "󰂄  {capacity}%";
            format-plugged = "󰂄  {capacity}%";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };

          "custom/power" = {
            format = "⏻ ";
            on-click = "wlogout";
            tooltip = false;
          };
        };
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(30, 30, 46, 0.9);
          color: #cdd6f4;
          border-radius: 12px;
          border: 2px solid #313244;
        }

        #workspaces button {
          padding: 0 10px;
          color: #cdd6f4;
          background-color: transparent;
          border: none;
          border-radius: 8px;
        }

        #workspaces button:hover {
          background: rgba(49, 50, 68, 0.8);
        }

        #workspaces button.focused {
          background-color: #89b4fa;
          color: #1e1e2e;
        }

        #workspaces button.active {
          background-color: #89b4fa;
          color: #1e1e2e;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #tray,
        #mode,
        #bluetooth,
        #custom-power {
          padding: 0 10px;
          color: #cdd6f4;
          border-radius: 8px;
          margin: 2px 4px;
        }

        #clock {
          background-color: #89b4fa;
          color: #1e1e2e;
        }

        #battery {
          background-color: #a6e3a1;
          color: #1e1e2e;
        }

        #battery.warning {
          background-color: #f9e2af;
        }

        #battery.critical {
          background-color: #f38ba8;
          color: #1e1e2e;
        }

        #network {
          background-color: #cba6f7;
          color: #1e1e2e;
        }

        #pulseaudio {
          background-color: #fab387;
          color: #1e1e2e;
        }

        #backlight {
          background-color: #f9e2af;
          color: #1e1e2e;
        }

        #bluetooth {
          background-color: #74c7ec;
          color: #1e1e2e;
        }

        #custom-power {
          background-color: #f38ba8;
          color: #1e1e2e;
          padding: 0 12px;
        }

        #tray {
          background-color: #313244;
        }

        #window {
          color: #cdd6f4;
        }

        tooltip {
          background: rgba(30, 30, 46, 0.95);
          border: 2px solid #313244;
          border-radius: 8px;
        }

        tooltip label {
          color: #cdd6f4;
        }
      '';
    };

    # Mako notification configuration
    services.mako = {
      enable = true;
      package = pkgsUnstable.mako;
      settings = {
        "default-timeout" = 5000;
        background-color = "#1e1e2e";
        text-color = "#cdd6f4";
        border-color = "#89b4fa";
        border-size = 2;
        border-radius = 10;
        padding = "12";
        margin = "10";
        font = "JetBrainsMono Nerd Font 11";
      };
      extraConfig = ''
        [urgency=high]
        background-color=#f38ba8
        text-color=#1e1e2e
        border-color=#f38ba8
      '';
    };

    # Wlogout configuration
    programs.wlogout = {
      enable = true;
      package = pkgsUnstable.wlogout;

      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];

      style = ''
        * {
          background-image: none;
          font-family: "JetBrainsMono Nerd Font";
        }

        window {
          background-color: rgba(30, 30, 46, 0.95);
        }

        button {
          color: #cdd6f4;
          background-color: #313244;
          border: 2px solid #45475a;
          border-radius: 16px;
          margin: 10px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
        }

        button:focus, button:active, button:hover {
          background-color: #89b4fa;
          color: #1e1e2e;
          outline-style: none;
        }

        #lock {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/lock.png"));
        }

        #logout {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/logout.png"));
        }

        #suspend {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/suspend.png"));
        }

        #hibernate {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/hibernate.png"));
        }

        #shutdown {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/shutdown.png"));
        }

        #reboot {
          background-image: image(url("${pkgsUnstable.wlogout}/share/wlogout/icons/reboot.png"));
        }
      '';
    };

    # Rofi configuration
    programs.rofi = {
      enable = true;
      package = pkgsUnstable.rofi;
      font = "JetBrainsMono Nerd Font 12";
      terminal = "ghostty";
      theme = "~/.config/rofi/theme.rasi";
      extraConfig = {
        modi = "drun,run,window";
        show-icons = true;
        drun-display-format = "{name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "  Apps  ";
        display-run = "  Run  ";
        display-window = "  Window  ";
      };
    };

    # Create Rofi theme file
    home.file.".config/rofi/theme.rasi".text = ''
      * {
        bg: #1e1e2e;
        bg-alt: #313244;
        fg: #cdd6f4;
        fg-alt: #a6adc8;

        blue: #89b4fa;
        lavender: #b4befe;
        sapphire: #74c7ec;
        sky: #89dceb;
        teal: #94e2d5;
        green: #a6e3a1;
        yellow: #f9e2af;
        peach: #fab387;
        maroon: #eba0ac;
        red: #f38ba8;
        mauve: #cba6f7;
        pink: #f5c2e7;
        flamingo: #f2cdcd;
        rosewater: #f5e0dc;

        background-color: @bg;
        text-color: @fg;
      }

      window {
        width: 50%;
        height: 60%;
        border: 2px;
        border-color: @lavender;
        border-radius: 16px;
        background-color: @bg;
      }

      mainbox {
        background-color: transparent;
        children: [inputbar, listview];
        spacing: 10px;
        padding: 10px;
      }

      inputbar {
        background-color: @bg-alt;
        border-radius: 12px;
        padding: 10px 15px;
        children: [prompt, entry];
        spacing: 10px;
      }

      prompt {
        background-color: transparent;
        text-color: @blue;
        font: "JetBrainsMono Nerd Font 14";
      }

      entry {
        background-color: transparent;
        text-color: @fg;
        font: "JetBrainsMono Nerd Font 12";
        placeholder: "Search...";
        placeholder-color: @fg-alt;
        cursor: text;
      }

      listview {
        background-color: transparent;
        columns: 1;
        lines: 10;
        spacing: 5px;
        fixed-height: false;
        dynamic: true;
      }

      element {
        background-color: transparent;
        padding: 10px 15px;
        border-radius: 10px;
        spacing: 10px;
      }

      element-icon {
        background-color: transparent;
        size: 24px;
      }

      element-text {
        background-color: transparent;
        text-color: @fg;
        font: "JetBrainsMono Nerd Font 12";
      }

      element selected {
        background-color: @blue;
        text-color: @bg;
      }

      element selected .element-text {
        text-color: @bg;
      }

      mode-switcher {
        background-color: transparent;
      }

      button {
        background-color: @bg-alt;
        text-color: @fg;
        padding: 5px 10px;
        border-radius: 8px;
      }

      button selected {
        background-color: @mauve;
        text-color: @bg;
      }
    '';
  };
}

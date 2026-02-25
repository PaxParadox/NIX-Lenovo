# Hyprland Module
# Hyprland window manager with Tokyo Night theme and Bibata cursor
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myModules.hyprland;

  # Tokyo Night colors
  colors = {
    bg = "1a1b26";
    bg_dark = "16161e";
    bg_highlight = "292e42";
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
  };
in {
  options.myModules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";

    modKey = lib.mkOption {
      type = lib.types.enum ["SUPER" "ALT"];
      default = "SUPER";
      description = "Modifier key for Hyprland keybindings (SUPER or ALT)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        # Monitor configuration (will auto-detect)
        monitor = ",preferred,auto,auto";

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = false;
        };

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "0xee${colors.blue}";
          "col.inactive_border" = "0x66${colors.bg_highlight}";
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "0x66000000";
          };
        };

        # Animation settings
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Layout settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        # Misc
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        # Window rules
        windowrulev2 = [
          "float,class:^(pavucontrol)$"
          "float,class:^(wofi)$"
          "float,class:^(rofi)$"
        ];

        # Keybindings
        "$mod" = cfg.modKey;
        "$terminal" = "kitty";
        "$fileManager" = "nautilus";
        "$menu" = "rofi -show drun";
        "$browser" = "zen-beta";

        bind = [
          # Basic binds
          "$mod, RETURN, exec, $terminal"
          "$mod, Q, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, O, exec, $browser"
          "$mod, V, togglefloating,"
          "$mod, R, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"
          "$mod, F, fullscreen,"
          "$mod, L, exec, hyprlock"

          # Screenshot
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "SHIFT, Print, exec, grim - | wl-copy"

          # Move focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move windows
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Switch workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Scroll through workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bindel = [
          # Volume
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          # Brightness
          ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # Autostart
        exec-once = [
          "waybar"
          "swaync"
          "swww-daemon"
          "sleep 1 && swww img ~/NIX-Lenovo/wallpapers/Tokyo-Night.jpg"
        ];
      };

      # Gestures - 3 finger swipe to switch workspaces
      extraConfig = ''
        gesture = 3, horizontal, workspace
      '';
    };

    # Rofi configuration
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      font = "JetBrainsMono Nerd Font 12";
      theme = builtins.toFile "tokyo-night.rasi" ''
        * {
          bg: #${colors.bg};
          bg-alt: #${colors.bg_dark};
          fg: #${colors.fg};
          fg-alt: #${colors.fg_dark};
          blue: #${colors.blue};
          red: #${colors.red};
          green: #${colors.green};
          yellow: #${colors.yellow};
          magenta: #${colors.magenta};
          cyan: #${colors.cyan};

          background-color: @bg;
          text-color: @fg;
        }

        window {
          width: 600;
          border-radius: 10;
          background-color: @bg;
          border: 2px solid;
          border-color: @blue;
          padding: 20;
        }

        mainbox {
          background-color: transparent;
          children: [inputbar, listview];
          spacing: 15;
        }

        inputbar {
          background-color: @bg-alt;
          border-radius: 5;
          padding: 10;
          children: [prompt, entry];
        }

        prompt {
          background-color: transparent;
          text-color: @blue;
          padding: 0 10 0 0;
        }

        entry {
          background-color: transparent;
          text-color: @fg;
          placeholder: "Search...";
          placeholder-color: @fg-alt;
        }

        listview {
          background-color: transparent;
          columns: 1;
          lines: 8;
          spacing: 5;
          fixed-height: false;
          dynamic: true;
        }

        element {
          background-color: transparent;
          padding: 10;
          border-radius: 5;
        }

        element normal.normal {
          background-color: transparent;
          text-color: @fg;
        }

        element selected.normal {
          background-color: @blue;
          text-color: @bg;
        }

        element-icon {
          background-color: transparent;
          size: 24;
          margin: 0 10 0 0;
        }

        element-text {
          background-color: transparent;
          text-color: inherit;
        }
      '';
    };

    # Hyprlock configuration
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(${colors.fg})";
            inner_color = "rgb(${colors.bg})";
            outer_color = "rgb(${colors.blue})";
            outline_thickness = 5;
            placeholder_text = ''<span foreground="##${colors.fg_dark}">Password...</span>'';
            shadow_passes = 2;
          }
        ];

        label = [
          {
            monitor = "";
            position = "0, 80";
            text = ''Hi there, $USER'';
            color = "rgb(${colors.fg})";
            font_size = 25;
            font_family = "JetBrainsMono Nerd Font";
          }
          {
            monitor = "";
            position = "0, -150";
            text = "$TIME";
            color = "rgb(${colors.fg})";
            font_size = 50;
            font_family = "JetBrainsMono Nerd Font";
          }
        ];
      };
    };

    # Cursor theme
    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # GTK theme
    gtk = {
      enable = true;
      theme = {
        name = "Tokyo-Night-Dark";
        package = pkgs.tokyonight-gtk-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    # Ensure dark theme is used for GTK apps
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Tokyo-Night-Dark";
        icon-theme = "Papirus-Dark";
        cursor-theme = "Bibata-Modern-Classic";
      };
    };

    # Additional packages
    home.packages = with pkgs; [
      brightnessctl
      pavucontrol
      papirus-icon-theme
      tokyonight-gtk-theme
      bibata-cursors
      wl-clipboard
    ];
  };
}

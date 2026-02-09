# GNOME Shell Configuration Module
#
# Customize GNOME Shell with extensions, settings, and keybindings
# for a productive desktop experience.

{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:

with lib;

let
  cfg = config.myModules.gnome;
in {
  options.myModules.gnome = {
    enable = mkEnableOption "GNOME Shell customization with extensions";

    extensions = {
      user-themes = mkEnableOption "User Themes extension (custom shell themes)" // { default = true; };
      blur-my-shell = mkEnableOption "Blur My Shell extension" // { default = true; };
      dash-to-dock = mkEnableOption "Dash to Dock extension" // { default = true; };
      appindicator = mkEnableOption "AppIndicator extension (tray icons)" // { default = true; };
      clipboard-history = mkEnableOption "Clipboard History extension" // { default = true; };
      caffeine = mkEnableOption "Caffeine extension (disable auto-suspend)" // { default = false; };
      rounded-corners = mkEnableOption "Rounded Window Corners extension" // { default = true; };
      vitals = mkEnableOption "Vitals extension (system monitor)" // { default = false; };
    };

    settings = {
      disable-animations = mkEnableOption "disable animations" // { default = false; };
      show-battery-percentage = mkEnableOption "show battery percentage" // { default = true; };
      clock-show-seconds = mkEnableOption "show seconds in clock" // { default = false; };
      clock-show-weekday = mkEnableOption "show weekday in clock" // { default = true; };
      enable-hot-corners = mkEnableOption "enable hot corners" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # GNOME Shell extensions
    home.packages = with pkgs.gnomeExtensions; [
      # Install enabled extensions
      (mkIf cfg.extensions.user-themes user-themes)
      (mkIf cfg.extensions.blur-my-shell blur-my-shell)
      (mkIf cfg.extensions.dash-to-dock dash-to-dock)
      (mkIf cfg.extensions.appindicator appindicator)
      (mkIf cfg.extensions.clipboard-history clipboard-history)
      (mkIf cfg.extensions.caffeine caffeine)
      (mkIf cfg.extensions.rounded-corners rounded-window-corners-reborn)
      (mkIf cfg.extensions.vitals vitals)
    ];

    # Enable GNOME Shell integration
    programs.gnome-shell = {
      enable = true;
      
      # Enable installed extensions
      extensions = [
        (mkIf cfg.extensions.user-themes { package = pkgs.gnomeExtensions.user-themes; })
        (mkIf cfg.extensions.blur-my-shell { package = pkgs.gnomeExtensions.blur-my-shell; })
        (mkIf cfg.extensions.dash-to-dock { package = pkgs.gnomeExtensions.dash-to-dock; })
        (mkIf cfg.extensions.appindicator { package = pkgs.gnomeExtensions.appindicator; })
        (mkIf cfg.extensions.clipboard-history { package = pkgs.gnomeExtensions.clipboard-history; })
        (mkIf cfg.extensions.caffeine { package = pkgs.gnomeExtensions.caffeine; })
        (mkIf cfg.extensions.rounded-corners { package = pkgs.gnomeExtensions.rounded-window-corners-reborn; })
        (mkIf cfg.extensions.vitals { package = pkgs.gnomeExtensions.vitals; })
      ];
    };

    # GNOME Shell settings via dconf
    dconf.settings = {
      # Note: enabled-extensions is handled by programs.gnome-shell.extensions
      # We configure other GNOME Shell settings here
      "org/gnome/shell" = {
        # Favorite apps in dock
        favorite-apps = [
          "zen-beta.desktop"
          "firefox.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      # GNOME interface settings
      "org/gnome/desktop/interface" = {
        enable-animations = !cfg.settings.disable-animations;
        show-battery-percentage = cfg.settings.show-battery-percentage;
        clock-show-seconds = cfg.settings.clock-show-seconds;
        clock-show-weekday = cfg.settings.clock-show-weekday;
      };

      # GNOME Shell settings
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = false;
      };

      # Enable/disable hot corners
      "org/gnome/desktop/interface" = {
        enable-hot-corners = cfg.settings.enable-hot-corners;
      };

      # Dash to Dock settings (if enabled)
      "org/gnome/shell/extensions/dash-to-dock" = mkIf cfg.extensions.dash-to-dock {
        dock-position = "LEFT";
        show-apps-at-top = true;
        dash-max-icon-size = 48;
        autohide = true;
        intellihide = true;
        show-mounts = true;
        show-trash = true;
        custom-theme-shrink = true;
        transparency-mode = "FIXED";
        background-opacity = 0.8;
      };

      # Blur My Shell settings (if enabled)
      "org/gnome/shell/extensions/blur-my-shell" = mkIf cfg.extensions.blur-my-shell {
        brightness = 0.9;
        dash-opacity = 0.9;
        sigma = 25;
        # Panel and dock blur
        panel-blur = true;
        dash-blur = true;
        # Application blur (for supported apps)
        appfolder-dialog-blur = true;
        # Overview blur
        overview-blur = true;
      };

      # Clipboard History settings (if enabled)
      "org/gnome/shell/extensions/clipboard-history" = mkIf cfg.extensions.clipboard-history {
        history-size = 50;
        cache-size = 100;
        move-item-first = true;
        toggle-private-mode = [ "<Super>semicolon" ];
      };

      # Caffeine settings (if enabled)
      "org/gnome/shell/extensions/caffeine" = mkIf cfg.extensions.caffeine {
        show-indicator = true;
        show-notification = false;
        toggle-shortcut = [ "<Super>c" ];
      };

      # Rounded Corners settings (if enabled)
      "org/gnome/shell/extensions/rounded-window-corners" = mkIf cfg.extensions.rounded-corners {
        border-width = 1;
        corner-radius = 12;
        # Corners settings
        top-left = true;
        top-right = true;
        bottom-left = true;
        bottom-right = true;
      };

      # Vitals settings (if enabled)
      "org/gnome/shell/extensions/vitals" = mkIf cfg.extensions.vitals {
        show-cpu = true;
        show-memory = true;
        show-temperature = true;
        show-network = true;
        show-storage = false;
        show-battery = true;
        position-in-panel = 0; # Right side
      };

      # User Themes - set shell theme (if enabled and using catppuccin)
      "org/gnome/shell/extensions/user-theme" = mkIf (cfg.extensions.user-themes && config.myModules.theming.enable) {
        name = "Catppuccin-Mocha";
      };

      # Workspaces
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        workspaces-only-on-primary = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
        workspace-names = [ "Work" "Web" "Chat" "Media" ];
      };

      # Keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };

      # Custom keybinding: Open Terminal (Ghostty)
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Open Terminal";
        command = "ghostty";
        binding = "<Super>Return";
      };

      # Custom keybinding: Launch App (Rofi or GNOME overview)
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Launch App";
        command = "rofi -show drun -show-icons";
        binding = "<Super>r";
      };

      # Custom keybinding: Screenshot
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "Screenshot Area";
        command = "gnome-screenshot -a -f /home/paradox/Pictures/Screenshots/$(date +%Y-%m-%d-%H-%M-%S).png";
        binding = "<Shift>Print";
      };
    };

    # Ensure screenshot directory exists
    home.file."Pictures/Screenshots/.keep".text = "";
  };
}

# Home Manager Configuration
#
# Main entry point for home-manager configuration.
# Imports modular configurations and sets up per-host customization.

{ config, pkgs, lib, inputs, pkgsUnstable, pkgsMaster, ... }:

let
  # Detect hostname for per-host customization
  # Uses HOSTNAME environment variable, defaults to "unknown"
  hostname = builtins.getEnv "HOSTNAME";

  # Check if running on specific hosts
  isLaptop = hostname == "lenovonix" || hostname == "";
  isDesktop = hostname == "desktop";
in {
  imports = [
    # Core module (always enabled)
    ./modules/core.nix

    # Feature modules (toggleable)
    ./modules/shells.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/terminal.nix
    ./modules/media.nix
    ./modules/browsers.nix
    ./modules/hyprland.nix
    ./modules/theming.nix
    ./modules/gnome.nix
  ];

  # Module configuration
  # Toggle modules on/off and customize options here
  myModules = {
    # Shell configuration
    shells = {
      enable = true;
      defaultShell = "bash";  # Options: "bash", "fish", "none"
    };

    # Git configuration
    git = {
      enable = true;
    };

    # Editor configuration (Neovim + VS Code:)
    editors = {
      enable = true;
      defaultEditor = "nvim";  # Options: "nvim", "vscode", "none"

      # VS Code: settings
      vscode = {
        theme = "Dark Modern";
        fontSize = 14;
      };
    };

    # Terminal configuration
    terminal = {
      enable = true;

      ghostty = {
        theme = "Builtin Dark";
        fontSize = 11;
      };
    };

    # Future modules (currently disabled)
    media = {
      enable = false;
    };

    # Browser configuration
    browsers = {
      enable = true;
      defaultBrowser = "zen";  # Options: "zen", "firefox", "chromium", "brave", "vivaldi", "none"

      # Enable/disable individual browsers
      zen.enable = true;
      firefox.enable = true;
      chromium.enable = true;
      brave.enable = true;
      vivaldi.enable = true;
    };

    # Hyprland configuration
    hyprland = {
      enable = true;
      # Uncomment and modify if you have specific monitor requirements
      # monitor = "eDP-1,1920x1080@60,0x0,1";
    };

    # Theming configuration - pick your theme!
    theming = {
      enable = true;
      # Available themes:
      # - "catppuccin-mocha"  (default, warm pastel - most popular)
      # - "nord"              (cold arctic blue tones)
      # - "gruvbox-dark"      (retro warm amber/orange)
      # - "dracula"           (vibrant purple/pink)
      # - "tokyo-night"       (neon cyber dark blue)
      # - "rose-pine"         (soft elegant pink/beige)
      theme = "tokyo-night";
    };

    # GNOME Shell customization with extensions
    gnome = {
      enable = true;
      
      # Extensions - enable/disable as needed
      extensions = {
        # Visual enhancements
        user-themes = true;      # Custom shell themes
        blur-my-shell = false;    # Blur effects for shell
        rounded-corners = false;  # Rounded window corners
        just-perfection = true;  # Fine-tune GNOME UI
        
        # Dock & taskbar
        dash-to-dock = false;     # Better dock
        
        # System tray & utilities
        appindicator = true;     # System tray icons
        clipboard-history = true; # Clipboard manager
        sound-output-device-chooser = true; # Quick audio switching
        
        # Tiling window management
        pop-shell = false;        # Tiling WM features
        
        # Phone integration
        gsconnect = true;        # KDE Connect for GNOME
        
        # Optional (disabled by default)
        caffeine = true;        # Prevent auto-suspend
        vitals = true;          # System monitor in panel
      };

      # GNOME settings
      settings = {
        disable-animations = false;
        show-battery-percentage = true;
        clock-show-seconds = false;
        clock-show-weekday = true;
        enable-hot-corners = true;
      };
    };
  };

  # Per-host package additions
  # Add packages specific to certain hosts here
  home.packages = lib.mkIf isDesktop (with pkgs; [
    # Desktop-specific packages
    # discord
    # steam-run
  ]);
}

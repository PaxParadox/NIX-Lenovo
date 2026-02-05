# Theming Configuration Module
#
# Unified GTK, Qt, and application theming with popular dark themes.

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.theming;

  # Theme definitions
  themes = {
    catppuccin-mocha = {
      name = "Catppuccin-Mocha";
      gtkTheme = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accent = "mauve";
      };
      iconTheme = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
      cursorTheme = pkgs.catppuccin-cursors;
      cursorName = "catppuccin-mocha-dark-cursors";
      qtStyle = "kvantum";
      colors = {
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        blue = "#89b4fa";
        lavender = "#b4befe";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        teal = "#94e2d5";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        peach = "#fab387";
        maroon = "#eba0ac";
        red = "#f38ba8";
        mauve = "#cba6f7";
        pink = "#f5c2e7";
        flamingo = "#f2cdcd";
        rosewater = "#f5e0dc";
      };
    };

    nord = {
      name = "Nord";
      gtkTheme = pkgs.nordic;
      iconTheme = pkgs.nordzy-icon-theme;
      cursorTheme = pkgs.nordzy-cursor-theme;
      cursorName = "Nordzy-cursors";
      qtStyle = "kvantum";
      colors = {
        base = "#2e3440";
        mantle = "#3b4252";
        crust = "#242933";
        text = "#eceff4";
        subtext1 = "#e5e9f0";
        subtext0 = "#d8dee9";
        overlay2 = "#81a1c1";
        overlay1 = "#5e81ac";
        overlay0 = "#4c566a";
        surface2 = "#434c5e";
        surface1 = "#3b4252";
        surface0 = "#2e3440";
        blue = "#81a1c1";
        lavender = "#b48ead";
        sapphire = "#88c0d0";
        sky = "#88c0d0";
        teal = "#8fbcbb";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        peach = "#d08770";
        maroon = "#bf616a";
        red = "#bf616a";
        mauve = "#b48ead";
        pink = "#b48ead";
        flamingo = "#d08770";
        rosewater = "#eceff4";
      };
    };

    gruvbox-dark = {
      name = "Gruvbox-Dark";
      gtkTheme = pkgs.gruvbox-gtk-theme;
      iconTheme = pkgs.gruvbox-plus-icons;
      cursorTheme = pkgs.bibata-cursors;
      cursorName = "Bibata-Modern-Ice";
      qtStyle = "kvantum";
      colors = {
        base = "#282828";
        mantle = "#1d2021";
        crust = "#161819";
        text = "#ebdbb2";
        subtext1 = "#d5c4a1";
        subtext0 = "#bdae93";
        overlay2 = "#a89984";
        overlay1 = "#928374";
        overlay0 = "#7c6f64";
        surface2 = "#504945";
        surface1 = "#3c3836";
        surface0 = "#32302f";
        blue = "#83a598";
        lavender = "#d3869b";
        sapphire = "#83a598";
        sky = "#83a598";
        teal = "#8ec07c";
        green = "#b8bb26";
        yellow = "#fabd2f";
        peach = "#fe8019";
        maroon = "#cc241d";
        red = "#fb4934";
        mauve = "#d3869b";
        pink = "#d3869b";
        flamingo = "#fe8019";
        rosewater = "#fbf1c7";
      };
    };

    dracula = {
      name = "Dracula";
      gtkTheme = pkgs.dracula-theme;
      iconTheme = pkgs.papirus-icon-theme;
      cursorTheme = pkgs.bibata-cursors;
      cursorName = "Bibata-Modern-Ice";
      qtStyle = "kvantum";
      colors = {
        base = "#282a36";
        mantle = "#1e1f29";
        crust = "#191a21";
        text = "#f8f8f2";
        subtext1 = "#e6e6dc";
        subtext0 = "#bfbfbf";
        overlay2 = "#6272a4";
        overlay1 = "#44475a";
        overlay0 = "#3d4051";
        surface2 = "#6272a4";
        surface1 = "#44475a";
        surface0 = "#343746";
        blue = "#8be9fd";
        lavender = "#bd93f9";
        sapphire = "#8be9fd";
        sky = "#8be9fd";
        teal = "#50fa7b";
        green = "#50fa7b";
        yellow = "#f1fa8c";
        peach = "#ffb86c";
        maroon = "#ff5555";
        red = "#ff5555";
        mauve = "#bd93f9";
        pink = "#ff79c6";
        flamingo = "#ff79c6";
        rosewater = "#f8f8f2";
      };
    };

    tokyo-night = {
      name = "Tokyo-Night";
      gtkTheme = pkgs.tokyo-night-gtk;
      iconTheme = pkgs.tela-icon-theme;
      cursorTheme = pkgs.bibata-cursors;
      cursorName = "Bibata-Modern-Ice";
      qtStyle = "kvantum";
      colors = {
        base = "#1a1b26";
        mantle = "#16161e";
        crust = "#13131a";
        text = "#a9b1d6";
        subtext1 = "#c0caf5";
        subtext0 = "#9aa5ce";
        overlay2 = "#565f89";
        overlay1 = "#4e5173";
        overlay0 = "#414868";
        surface2 = "#3b4261";
        surface1 = "#2f3549";
        surface0 = "#24283b";
        blue = "#7aa2f7";
        lavender = "#bb9af7";
        sapphire = "#2ac3de";
        sky = "#7dcfff";
        teal = "#1abc9c";
        green = "#9ece6a";
        yellow = "#e0af68";
        peach = "#ff9e64";
        maroon = "#f7768e";
        red = "#f7768e";
        mauve = "#bb9af7";
        pink = "#ff007c";
        flamingo = "#ff9e64";
        rosewater = "#c0caf5";
      };
    };

    rose-pine = {
      name = "Rosé-Pine";
      gtkTheme = pkgs.rose-pine-gtk-theme;
      iconTheme = pkgs.papirus-icon-theme;
      cursorTheme = pkgs.bibata-cursors;
      cursorName = "Bibata-Modern-Ice";
      qtStyle = "kvantum";
      colors = {
        base = "#191724";
        mantle = "#1f1d2e";
        crust = "#16141f";
        text = "#e0def4";
        subtext1 = "#fffaf3";
        subtext0 = "#f2e9de";
        overlay2 = "#6e6a86";
        overlay1 = "#908caa";
        overlay0 = "#524f67";
        surface2 = "#6e6a86";
        surface1 = "#403d52";
        surface0 = "#26233a";
        blue = "#31748f";
        lavender = "#c4a7e7";
        sapphire = "#31748f";
        sky = "#9ccfd8";
        teal = "#9ccfd8";
        green = "#31748f";
        yellow = "#f6c177";
        peach = "#ebbcba";
        maroon = "#eb6f92";
        red = "#eb6f92";
        mauve = "#c4a7e7";
        pink = "#c4a7e7";
        flamingo = "#ebbcba";
        rosewater = "#e0def4";
      };
    };
  };

  selectedTheme = themes.${cfg.theme};
in {
  options.myModules.theming = {
    enable = mkEnableOption "unified system theming";

    theme = mkOption {
      type = types.enum [ "catppuccin-mocha" "nord" "gruvbox-dark" "dracula" "tokyo-night" "rose-pine" ];
      default = "catppuccin-mocha";
      description = "Select the color theme for GTK, Qt, and applications";
    };

    font = {
      name = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Default font family";
      };
      size = mkOption {
        type = types.int;
        default = 11;
        description = "Default font size";
      };
    };
  };

  config = mkIf cfg.enable {
    # GTK Theming
    gtk = {
      enable = true;
      theme = {
        name = selectedTheme.name;
        package = selectedTheme.gtkTheme;
      };
      iconTheme = {
        name = if cfg.theme == "catppuccin-mocha" then "Papirus-Dark" else selectedTheme.iconTheme.name;
        package = selectedTheme.iconTheme;
      };
      cursorTheme = {
        name = selectedTheme.cursorName;
        package = selectedTheme.cursorTheme;
      };
      font = {
        name = cfg.font.name;
        size = cfg.font.size;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    # Qt Theming
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = selectedTheme.qtStyle;
    };

    # Theme packages
    home.packages = with pkgs; [
      # Theme packages
      selectedTheme.gtkTheme
      selectedTheme.iconTheme
      selectedTheme.cursorTheme
      
      # Additional theming tools
      nwg-look
      libsForQt5.qt5ct
      kdePackages.qt6ct
      
      # Kvantum for Qt theming
      libsForQt5.kvantum
      libsForQt5.kvantum-qt5
    ];

    # Cursor environment variable
    home.sessionVariables = {
      XCURSOR_THEME = selectedTheme.cursorName;
      XCURSOR_SIZE = "24";
    };

    # Dconf settings for GNOME/GTK apps
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = selectedTheme.name;
        icon-theme = if cfg.theme == "catppuccin-mocha" then "Papirus-Dark" else selectedTheme.iconTheme.name;
        cursor-theme = selectedTheme.cursorName;
      };
    };

    # Export theme colors for other modules to use
    home.sessionVariables.THEME_COLORS = builtins.toJSON selectedTheme.colors;
  };
}

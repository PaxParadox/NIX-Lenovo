# Terminal Module
#
# Terminal multiplexer (tmux) and terminal emulator (ghostty) configurations.
# Can be toggled on/off and customized with options.
{
  config,
  pkgs,
  pkgsUnstable,
  pkgsMaster,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.terminal;
in {
  options.myModules.terminal = {
    enable = mkEnableOption "terminal configurations (tmux, ghostty, alacritty)";

    ghostty = {
      fontSize = mkOption {
        type = types.int;
        default = 11;
        description = "Ghostty terminal font size";
      };
    };

    alacritty = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Alacritty terminal";
      };

      fontSize = mkOption {
        type = types.int;
        default = 11;
        description = "Alacritty terminal font size";
      };

      theme = mkOption {
        type = types.str;
        default = "tokyo-night-dark";
        description = "Alacritty color theme";
      };
    };
  };

  config = mkIf cfg.enable {
    # Tmux configuration
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "screen-256color";

      extraConfig = ''
        set-option -g mouse on
        set-option -g status-style bg=black
      '';
    };

    # Ghostty terminal configuration
    programs.ghostty = {
      enable = true;
      package = pkgsMaster.ghostty;

      settings = {
        font-size = cfg.ghostty.fontSize;
        window-padding-x = 10;
        window-padding-y = 10;
      };

      # Shell integration always enabled for better terminal experience
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    # Alacritty terminal configuration
    home.packages = lib.mkIf cfg.alacritty.enable [pkgsUnstable.alacritty];

    programs.alacritty = lib.mkIf cfg.alacritty.enable {
      enable = true;
      package = pkgsUnstable.alacritty;

      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          decorations = "full";
        };

        font = {
          size = cfg.alacritty.fontSize;
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
        };

        colors = {
          # Tokyo Night Dark theme
          primary = {
            background = "#1a1b26";
            foreground = "#c0caf5";
          };

          normal = {
            black = "#15161e";
            red = "#f7768e";
            green = "#9ece6a";
            yellow = "#e0af68";
            blue = "#7aa2f7";
            magenta = "#bb9af7";
            cyan = "#7dcfff";
            white = "#a9b1d6";
          };

          bright = {
            black = "#414868";
            red = "#f7768e";
            green = "#9ece6a";
            yellow = "#e0af68";
            blue = "#7aa2f7";
            magenta = "#bb9af7";
            cyan = "#7dcfff";
            white = "#c0caf5";
          };
        };
      };
    };
  };
}

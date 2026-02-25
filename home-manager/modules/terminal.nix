# Terminal Module
# Terminal multiplexer (tmux) and emulators (kitty, alacritty)
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.terminal;
in {
  options.myModules.terminal = {
    enable = mkEnableOption "terminal configurations (tmux, kitty, alacritty)";

    kitty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Kitty terminal";
      };

      fontSize = mkOption {
        type = types.int;
        default = 11;
        description = "Kitty terminal font size";
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

    # Kitty terminal (from unstable via overlay if needed)
    programs.kitty = mkIf cfg.kitty.enable {
      enable = true;
      settings = {
        font_size = cfg.kitty.fontSize;
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "JetBrainsMono Nerd Font Bold";
        italic_font = "JetBrainsMono Nerd Font Italic";
        bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";

        # Tokyo Night theme
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor = "#c0caf5";
        cursor_text_color = "#1a1b26";
        selection_background = "#283457";
        selection_foreground = "#c0caf5";
        url_color = "#73daca";

        # Black
        color0 = "#15161e";
        color8 = "#414868";

        # Red
        color1 = "#f7768e";
        color9 = "#f7768e";

        # Green
        color2 = "#9ece6a";
        color10 = "#9ece6a";

        # Yellow
        color3 = "#e0af68";
        color11 = "#e0af68";

        # Blue
        color4 = "#7aa2f7";
        color12 = "#7aa2f7";

        # Magenta
        color5 = "#bb9af7";
        color13 = "#bb9af7";

        # Cyan
        color6 = "#7dcfff";
        color14 = "#7dcfff";

        # White
        color7 = "#a9b1d6";
        color15 = "#c0caf5";

        # Window settings
        window_padding_width = 10;
        window_padding_height = 10;
        confirm_os_window_close = 0;
        enable_audio_bell = false;

        # Shell integration
        shell_integration = "enabled";
      };
      shellIntegration = {
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };

    # Alacritty terminal
    programs.alacritty = mkIf cfg.alacritty.enable {
      enable = true;

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

    # Terminal launcher aliases
    programs.bash.shellAliases = {
      t = "tmux";
      ta = "tmux attach";
    };

    programs.fish.shellAliases = {
      t = "tmux";
      ta = "tmux attach";
    };
  };
}

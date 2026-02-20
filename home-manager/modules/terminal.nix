# Terminal Module
#
# Terminal multiplexer (tmux) and terminal emulator (ghostty) configurations.
# Can be toggled on/off and customized with options.
{
  config,
  pkgs,
  pkgsMaster,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.terminal;
in {
  options.myModules.terminal = {
    enable = mkEnableOption "terminal configurations (tmux, ghostty)";

    ghostty = {
      fontSize = mkOption {
        type = types.int;
        default = 11;
        description = "Ghostty terminal font size";
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
  };
}

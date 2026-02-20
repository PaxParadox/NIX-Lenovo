# Shells Module
#
# Shell configurations (bash, fish) and shared aliases.
# Can be toggled on/off and customized per host.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.shells;
in {
  options.myModules.shells = {
    enable = mkEnableOption "shell configurations (bash, fish, aliases)";

    defaultShell = mkOption {
      type = types.enum ["bash" "fish" "none"];
      default = "bash";
      description = "Which shell to set as the default login shell";
    };
  };

  config = mkIf cfg.enable {
    # Shared shell aliases for all shells
    home.shellAliases = {
      ll = "eza -la";
      gs = "git status";
      gcm = "git commit -m";
    };

    # Bash configuration
    programs.bash = {
      enable = true;
    };

    # Fish shell configuration
    programs.fish = {
      enable = true;
      # Uncomment to customize fish greeting
      # shellInit = ''
      #   set -g fish_greeting ""
      # '';
    };

    # Set default shell if specified
    home.sessionVariables = mkIf (cfg.defaultShell != "none") {
      SHELL =
        if cfg.defaultShell == "fish"
        then "${pkgs.fish}/bin/fish"
        else "${pkgs.bash}/bin/bash";
    };
  };
}

# Git Module
#
# Git configuration and settings.
# Can be toggled on/off.

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.git;
in {
  options.myModules.git = {
    enable = mkEnableOption "git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      settings = {
        user.name = "Paradox";
        user.email = "paradox.main@protonmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}

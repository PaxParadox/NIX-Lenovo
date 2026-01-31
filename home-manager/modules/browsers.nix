# Browsers Module (Placeholder)
#
# Future module for web browsers.
# Examples: firefox, chromium, brave, etc.

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.browsers;
in {
  options.myModules.browsers = {
    enable = mkEnableOption "web browsers";
  };

  config = mkIf cfg.enable {
    # Add browser packages here when ready
    # home.packages = with pkgs; [
    #   firefox
    #   chromium
    #   brave
    # ];
  };
}

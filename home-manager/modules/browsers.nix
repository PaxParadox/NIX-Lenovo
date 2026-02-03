# Browsers Module (Placeholder)
#
# Future module for web browsers.
# Examples: firefox, chromium, brave, etc.

{ config, pkgs, inputs, lib, ... }:

with lib;

let
  cfg = config.myModules.browsers;
in {
  options.myModules.browsers = {
    enable = mkEnableOption "web browsers";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
  };
}

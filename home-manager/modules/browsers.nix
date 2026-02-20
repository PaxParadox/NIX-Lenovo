# Browsers Module
#
# Web browser configurations with selectable default.
# Supports: zen-browser, firefox, chromium, brave, vivaldi
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.browsers;
  browserOptions = ["zen" "firefox" "chromium" "brave" "vivaldi" "none"];
in {
  options.myModules.browsers = {
    enable = mkEnableOption "web browsers";

    defaultBrowser = mkOption {
      type = types.enum browserOptions;
      default = "zen";
      description = "Which browser to set as the system default";
    };

    zen = {
      enable = mkEnableOption "Zen browser" // {default = true;};
    };

    firefox = {
      enable = mkEnableOption "Firefox" // {default = true;};
    };

    chromium = {
      enable = mkEnableOption "Chromium" // {default = false;};
    };

    brave = {
      enable = mkEnableOption "Brave" // {default = false;};
    };

    vivaldi = {
      enable = mkEnableOption "Vivaldi" // {default = false;};
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.zen.enable [
        inputs.zen-browser.packages.${pkgs.system}.default
      ])
      (mkIf cfg.firefox.enable [
        pkgs.firefox
      ])
      (mkIf cfg.chromium.enable [
        pkgs.chromium
      ])
      (mkIf cfg.brave.enable [
        pkgs.brave
      ])
      (mkIf cfg.vivaldi.enable [
        pkgs.vivaldi
      ])
    ];

    # Set default browser using xdg-mime
    xdg.mimeApps = mkIf (cfg.defaultBrowser != "none") {
      enable = true;
      defaultApplications = let
        browserDesktop =
          {
            "zen" = "zen-beta.desktop";
            "firefox" = "firefox.desktop";
            "chromium" = "chromium-browser.desktop";
            "brave" = "brave-browser.desktop";
            "vivaldi" = "vivaldi-stable.desktop";
          }.${
            cfg.defaultBrowser
          };
      in {
        "text/html" = browserDesktop;
        "x-scheme-handler/http" = browserDesktop;
        "x-scheme-handler/https" = browserDesktop;
        "x-scheme-handler/about" = browserDesktop;
        "x-scheme-handler/unknown" = browserDesktop;
      };
    };

    # Set BROWSER environment variable
    home.sessionVariables = mkIf (cfg.defaultBrowser != "none") {
      BROWSER =
        {
          "zen" = "zen";
          "firefox" = "firefox";
          "chromium" = "chromium";
          "brave" = "brave";
          "vivaldi" = "vivaldi";
        }.${
          cfg.defaultBrowser
        };
    };
  };
}

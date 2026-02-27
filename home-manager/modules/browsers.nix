# Browsers Module
# Zen browser + Brave
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myModules.browsers;
in {
  options.myModules.browsers = {
    enable = lib.mkEnableOption "web browsers";

    defaultBrowser = lib.mkOption {
      type = lib.types.enum ["zen" "brave"];
      default = "zen";
      description = "Which browser to set as the system default";
    };

    zen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Zen browser";
      };
    };

    brave = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Brave browser";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkMerge [
      (lib.mkIf cfg.zen.enable [pkgs.zen-browser])
      (lib.mkIf cfg.brave.enable [pkgs.brave])
    ];

    # Set default browser
    xdg.mimeApps = lib.mkIf (cfg.defaultBrowser != "none") {
      enable = true;
      defaultApplications = let
        browserDesktop =
          {
            "zen" = "zen-beta.desktop";
            "brave" = "brave-browser.desktop";
          }
          .${
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
    home.sessionVariables = lib.mkIf (cfg.defaultBrowser != "none") {
      BROWSER =
        {
          "zen" = "zen";
          "brave" = "brave";
        }
        .${
          cfg.defaultBrowser
        };
    };
  };
}

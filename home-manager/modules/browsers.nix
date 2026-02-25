# Browsers Module
# Zen browser + Brave
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.browsers;
in {
  options.myModules.browsers = {
    enable = mkEnableOption "web browsers";

    defaultBrowser = mkOption {
      type = types.enum ["zen" "brave"];
      default = "zen";
      description = "Which browser to set as the system default";
    };

    zen = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Zen browser";
      };
    };

    brave = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Brave browser";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.zen.enable [pkgs.zen-browser])
      (mkIf cfg.brave.enable [pkgs.brave])
    ];

    # Set default browser
    xdg.mimeApps = mkIf (cfg.defaultBrowser != "none") {
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
    home.sessionVariables = mkIf (cfg.defaultBrowser != "none") {
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

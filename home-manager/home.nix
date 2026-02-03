# Home Manager Configuration
#
# Main entry point for home-manager configuration.
# Imports modular configurations and sets up per-host customization.

{ config, pkgs, lib, inputs, pkgsUnstable, pkgsMaster, ... }:

let
  # Detect hostname for per-host customization
  # Uses HOSTNAME environment variable, defaults to "unknown"
  hostname = builtins.getEnv "HOSTNAME";

  # Check if running on specific hosts
  isLaptop = hostname == "lenovonix" || hostname == "";
  isDesktop = hostname == "desktop";
in {
  imports = [
    # Core module (always enabled)
    ./modules/core.nix

    # Feature modules (toggleable)
    ./modules/shells.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/terminal.nix
    ./modules/media.nix
    ./modules/browsers.nix
  ];

  # Module configuration
  # Toggle modules on/off and customize options here
  myModules = {
    # Shell configuration
    shells = {
      enable = true;
      defaultShell = "bash";  # Options: "bash", "fish", "none"
    };

    # Git configuration
    git = {
      enable = true;
    };

    # Editor configuration (Neovim + VS Code:)
    editors = {
      enable = true;
      defaultEditor = "nvim";  # Options: "nvim", "vscode", "none"

      # VS Code: settings
      vscode = {
        theme = "Dark Modern";
        fontSize = 14;
      };
    };

    # Terminal configuration
    terminal = {
      enable = true;

      ghostty = {
        theme = "Builtin Dark";
        fontSize = 11;
      };
    };

    # Future modules (currently disabled)
    media = {
      enable = false;
    };

    browsers = {
      enable = false;
    };
  };

  # Per-host package additions
  # Add packages specific to certain hosts here
  home.packages = lib.mkIf isDesktop (with pkgs; [
    # Desktop-specific packages
    # discord
    # steam-run
  ]);
}

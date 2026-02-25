# Home Manager Configuration
# Clean, minimal configuration for Hyprland desktop
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./modules/core.nix
    ./modules/shells.nix
    ./modules/git.nix
    ./modules/editors.nix
    ./modules/terminal.nix
    ./modules/browsers.nix
    ./modules/hyprland.nix
    ./modules/waybar.nix
  ];

  # Module configuration
  myModules = {
    shells.enable = true;
    shells.defaultShell = "fish";

    git.enable = true;

    editors.enable = true;

    terminal.enable = true;
    terminal.kitty.enable = true;
    terminal.alacritty.enable = true;

    browsers.enable = true;
    browsers.zen.enable = true;
    browsers.brave.enable = true;
    browsers.defaultBrowser = "zen";

    hyprland.enable = true;
    hyprland.modKey = "SUPER";

    waybar.enable = true;
    waybar.position = "top";
    waybar.height = 44;
  };

  # Home configuration - defined ONLY here, not in modules
  home.username = "paradox";
  home.homeDirectory = "/home/paradox";
  home.stateVersion = "25.11";

  # Enable home-manager
  programs.home-manager.enable = true;
}

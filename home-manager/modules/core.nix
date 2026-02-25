# Core Module
# Essential packages and base configuration
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Basic home settings
  home.username = "paradox";
  home.homeDirectory = "/home/paradox";
  home.stateVersion = "25.11";

  # Essential packages for all setups
  home.packages = with pkgs; [
    # CLI utilities
    htop
    ripgrep
    fd
    eza
    bat
    wget

    # System tools
    git
    tmux
    mediawriter

    # VPN tools
    tailscale
    ktailctl

    # Remote access
    moonlight-qt

    # Shells
    bash
    fish

    # Editors (from overlays)
    zed-editor
    opencode
    kimi-cli

    # Desktop apps
    github-desktop
  ];

  # Enable home-manager to manage itself
  programs.home-manager.enable = true;

  # Qt styling
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
  };
}

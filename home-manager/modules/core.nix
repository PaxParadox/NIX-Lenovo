# Core Module
#
# Essential packages and base home configuration.
# This module is always enabled and provides the foundation
# for all other modules.

{ config, pkgs, pkgsUnstable, pkgsMaster, lib, ... }:

{
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
    
    # Shells
    bash
    fish
    
    # Editors from different channels
    pkgsUnstable.zed-editor
    pkgsMaster.opencode
    pkgsMaster.code-cursor
    pkgsMaster.warp-terminal
    github-desktop
  ];

  # Enable home-manager to manage itself
  programs.home-manager.enable = true;
}

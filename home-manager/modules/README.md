# Home-Manager Modules
#
# This directory contains modular home-manager configurations.
# Each module can be toggled on/off and customized via options.
#
# Available Modules:
# - core.nix: Essential packages (always enabled)
# - shells.nix: Bash, fish, and aliases
# - git.nix: Git configuration
# - editors.nix: Neovim and VS Code:
# - terminal.nix: Tmux and Ghostty
# - media.nix: Media applications (placeholder)
# - browsers.nix: Web browsers (placeholder)
#
# Usage:
# Import modules in home.nix and configure via myModules options.
#
# Example:
#   myModules = {
#     shells.enable = true;
#     shells.defaultShell = "fish";
#     editors.enable = true;
#     editors.defaultEditor = "nvim";
#   };

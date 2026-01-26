{ config, pkgs, inputs, ... }:

{
  home.username = "paradox";
  home.homeDirectory = "/home/paradox";
  home.stateVersion = "25.11";

  # Packages to install for the user
  home.packages = with pkgs; [
    neovim
    tmux
    fish
    bash
    # ghostty terminal - not sure if available in nixpkgs, let's search later
    # zed-editor - already installed system-wide, maybe we want via home-manager
    zed-editor
    git
    # Additional tools
    htop
    ripgrep
    fd
    eza
    bat
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Paradox";
    userEmail = "your-email@example.com"; # Please update this
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Shell configuration (bash)
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -la";
      gs = "git status";
      gcm = "git commit -m";
    };
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza -la";
      gs = "git status";
    };
    # Set fish as default shell if desired
    # shellInit = ''
    #   set -g fish_greeting ""
    # '';
  };

  # Neovim configuration (basic)
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-commentary
    ];
    extraConfig = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set-option -g mouse on
      set-option -g status-style bg=black
    '';
  };

  # Let home-manager manage its own state
  programs.home-manager.enable = true;
}
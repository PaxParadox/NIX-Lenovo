{
  config,
  pkgs,
  lib,
  inputs,
  pkgsUnstable,
  ...
}:

{
  home.username = "paradox";
  home.homeDirectory = "/home/paradox";
  home.stateVersion = "25.11";

  # Packages to install for the user
  home.packages = with pkgs;
    [
      tmux
      fish
      bash
      # ghostty
      git
      # Additional tools
      htop
      ripgrep
      fd
      eza
      bat
    ]
    ++ [
      # programs from unstable channel (latest version)
      pkgsUnstable.code-cursor
      pkgsUnstable.opencode
      pkgsUnstable.zed-editor
    ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Paradox";
      user.email = "your-email@example.com"; # Please update this
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # VS Code: configuration with extensions
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;

    profiles.default = {
      extensions = with pkgsUnstable.vscode-marketplace; [
        # Nix support
        jnoortheen.nix-ide # Full Nix IDE support (syntax, formatting, LSP)

        # Python development
        ms-python.python # Official Python extension
        ms-python.black-formatter # Code formatting
        ms-python.isort # Import sorting

        # Additional useful extensions
        vscodevim.vim # Optional: Vim keybindings (remove if not needed)
        github.copilot # Optional: GitHub Copilot (if you use it)
      ];

      # VS Code: settings (optional but recommended)
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "python.formatting.provider" = "black";
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "files.associations" = {
          "*.nix" = "nix";
        };
      };
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

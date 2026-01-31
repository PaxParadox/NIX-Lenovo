{
  config,
  pkgs,
  lib,
  inputs,
  pkgsUnstable,
  pkgsMaster,
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
      # programs from unstable channel (binary cache, faster rebuilds)
      pkgsUnstable.zed-editor
      # programs from master branch (latest version, may build from source)
      pkgsMaster.opencode
      pkgsMaster.code-cursor
      pkgsMaster.warp-terminal
    ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Paradox";
      user.email = "paradox.main@protonmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Shared shell aliases for all shells
  home.shellAliases = {
    ll = "eza -la";
    gs = "git status";
    gcm = "git commit -m";
  };

  # VS Code: configuration with extensions (VSCodium - OSS version)
  programs.vscode = {
    enable = true;
    package = pkgsMaster.vscodium;

    profiles.default = {
      extensions = with pkgsMaster.vscode-extensions; [
        # Nix support
        jnoortheen.nix-ide # Full Nix IDE support (syntax, formatting, LSP)

        # Python development (VSCodium-compatible)
        charliermarsh.ruff # Fast Python linter, formatter, and import organizer
        detachhead.basedpyright # Open-source type checker (Pyright fork)

        # AI coding assistant (VSCodium-compatible)
        continue.continue # Open-source AI code assistant

        # Additional useful extensions
        vscodevim.vim # Vim keybindings
      ];

      # VS Code: settings
      userSettings = {
        # Nix settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";

        # Ruff settings (replaces black, isort, flake8)
        "ruff.organizeImports" = true;
        "ruff.fixAll" = true;
        "ruff.lint.run" = "onSave";
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.fixAll" = "explicit";
            "source.organizeImports" = "explicit";
          };
        };

        # BasedPyright settings
        "python.analysis.typeCheckingMode" = "basic";

        # Continue settings
        "continue.enableTabAutocomplete" = true;

        # General editor settings
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
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
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

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    package = pkgsMaster.ghostty;
    settings = {
      theme = "Builtin Dark";
      font-size = 11;
      window-padding-x = 10;
      window-padding-y = 10;
    };
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Let home-manager manage its own state
  programs.home-manager.enable = true;
}

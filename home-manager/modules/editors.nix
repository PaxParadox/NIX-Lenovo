# Editors Module
#
# Editor configurations (Neovim, VS Code:).
# Can be toggled on/off and customized with options.

{ config, pkgs, pkgsMaster, lib, ... }:

with lib;

let
  cfg = config.myModules.editors;
in {
  options.myModules.editors = {
    enable = mkEnableOption "editor configurations (neovim, vscode)";
    
    defaultEditor = mkOption {
      type = types.enum [ "nvim" "vscode" "none" ];
      default = "nvim";
      description = "Which editor to set as the system default ($EDITOR)";
    };
    
    vscode = {
      theme = mkOption {
        type = types.str;
        default = "Dark Modern";
        description = "VS Code: color theme";
      };
      
      fontSize = mkOption {
        type = types.int;
        default = 14;
        description = "VS Code: editor font size";
      };
    };
  };

  config = mkIf cfg.enable {
    # Neovim configuration
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = cfg.defaultEditor == "nvim";
      
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

    # VS Code: configuration
    programs.vscode = {
      enable = true;
      package = pkgsMaster.vscodium;
      
      profiles.default = {
        extensions = with pkgsMaster.vscode-extensions; [
          # Nix support
          jnoortheen.nix-ide
          
          # Python development
          charliermarsh.ruff
          detachhead.basedpyright
          
          # AI assistant
          continue.continue
          
          # Vim keybindings
          vscodevim.vim
        ];
        
        userSettings = {
          # Nix settings
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          
          # Ruff settings
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
          
          # Editor settings from options
          "editor.tabSize" = 2;
          "editor.fontSize" = cfg.vscode.fontSize;
          "workbench.colorTheme" = cfg.vscode.theme;
          "files.associations" = {
            "*.nix" = "nix";
          };
        };
      };
    };

    # Set EDITOR environment variable
    home.sessionVariables = mkIf (cfg.defaultEditor != "none") {
      EDITOR = 
        if cfg.defaultEditor == "nvim" then "nvim"
        else "code";
    };
  };
}

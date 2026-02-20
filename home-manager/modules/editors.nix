# Editors Module
#
# Editor configurations (Neovim from unstable, VS Code:).
# Neovim plugins are managed by LazyVim (user's Lua config).
# Can be toggled on/off and customized with options.
{
  config,
  pkgs,
  pkgsUnstable,
  pkgsMaster,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.editors;
in {
  options.myModules.editors = {
    enable = mkEnableOption "editor configurations (neovim, vscode)";

    defaultEditor = mkOption {
      type = types.enum ["nvim" "vscode" "none"];
      default = "nvim";
      description = "Which editor to set as the system default ($EDITOR)";
    };

    vscode = {
      fontSize = mkOption {
        type = types.int;
        default = 14;
        description = "VS Code: editor font size";
      };
    };
  };

  config = mkIf cfg.enable {
    # Neovim from unstable - plugins managed by LazyVim (user's Lua config)
    # Zed editor from unstable
    home.packages = with pkgsUnstable; [
      neovim
      zed-editor
    ];

    # Create vi/vim aliases for neovim
    programs.bash.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };

    programs.fish.shellAliases = {
      vi = "nvim";
      vim = "nvim";
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
          "files.associations" = {
            "*.nix" = "nix";
          };
        };
      };
    };

    # Set EDITOR environment variable
    home.sessionVariables = mkIf (cfg.defaultEditor != "none") {
      EDITOR =
        if cfg.defaultEditor == "nvim"
        then "nvim"
        else "code";
    };

    home.file.".config/zed/settings.json".text = ''
      {
        "ui_font_size": 15,
        "buffer_font_size": 14,
        "buffer_font_family": "JetBrainsMono Nerd Font",
        "ui_font_family": "JetBrainsMono Nerd Font",
        "terminal": {
          "font_family": "JetBrainsMono Nerd Font",
          "font_size": 12
        },
        "tabs": {
          "file_icons": true,
          "git_status": true
        },
        "indent_guides": {
          "enabled": true
        },
        "preferred_line_length": 100,
        "soft_wrap": "preferred_line_length",
        "ensure_final_newline_on_save": true,
        "remove_trailing_whitespace_on_save": true,
        "format_on_save": "on",
        "auto_update": false,
        "features": {
          "copilot": false
        },
        "telemetry": {
          "metrics": false,
          "diagnostics": false
        }
      }
    '';

    # Zed keymap - simple bindings
    home.file.".config/zed/keymap.json".text = ''
      [
        {
          "context": "Workspace",
          "bindings": {
            "ctrl-shift-p": "command_palette::Toggle",
            "ctrl-p": "file_finder::Toggle",
            "ctrl-shift-f": "project_search::ToggleFocus",
            "ctrl-shift-e": "project_panel::ToggleFocus",
            "ctrl-shift-x": "workspace::CloseAllItemsAndPanes",
            "ctrl-w": "pane::CloseActiveItem"
          }
        },
        {
          "context": "Editor",
          "bindings": {
            "ctrl-s": "workspace::Save",
            "ctrl-f": "buffer_search::Deploy",
            "ctrl-h": "buffer_search::DeployReplace",
            "ctrl-/": "editor::ToggleComments",
            "ctrl-d": "editor::SelectNext",
            "ctrl-shift-d": "editor::DuplicateLine",
            "alt-up": "editor::MoveLineUp",
            "alt-down": "editor::MoveLineDown"
          }
        }
      ]
    '';
  };
}

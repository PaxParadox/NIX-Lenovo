# Editors Module
# Zed (unstable) + VSCodium (master) with development extensions
{
  config,
  pkgs,
  pkgsMaster,
  lib,
  ...
}: let
  cfg = config.myModules.editors;
in {
  options.myModules.editors = {
    enable = lib.mkEnableOption "editor configurations (zed, vscodium)";
  };

  config = lib.mkIf cfg.enable {
    # Zed editor settings
    home.file.".config/zed/settings.json".text = builtins.toJSON {
      theme = "Tokyo Night Dark";
      ui_font_size = 15;
      buffer_font_size = 14;
      buffer_font_family = "JetBrainsMono Nerd Font";
      ui_font_family = "JetBrainsMono Nerd Font";
      terminal = {
        font_family = "JetBrainsMono Nerd Font";
        font_size = 12;
      };
      tabs = {
        file_icons = true;
        git_status = true;
      };
      indent_guides = {
        enabled = true;
      };
      preferred_line_length = 100;
      soft_wrap = "preferred_line_length";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;
      format_on_save = "on";
      auto_update = false;
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      languages = {
        Nix = {
          language_servers = ["nixd" "!nil"];
        };
        Python = {
          language_servers = ["pyright" "ruff"];
        };
        Rust = {
          language_servers = ["rust-analyzer"];
        };
      };
      lsp = {
        rust-analyzer = {
          binary = {
            path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
        };
        pyright = {
          binary = {
            path = "${pkgs.pyright}/bin/pyright-langserver";
          };
        };
        ruff = {
          binary = {
            path = "${pkgs.ruff}/bin/ruff-lsp";
          };
        };
        nixd = {
          binary = {
            path = "${pkgs.nixd}/bin/nixd";
          };
        };
      };
    };

    # Zed keymap
    home.file.".config/zed/keymap.json".text = builtins.toJSON [
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-p" = "command_palette::Toggle";
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-shift-f" = "project_search::ToggleFocus";
          "ctrl-shift-e" = "project_panel::ToggleFocus";
          "ctrl-shift-x" = "workspace::CloseAllItemsAndPanes";
          "ctrl-w" = "pane::CloseActiveItem";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-s" = "workspace::Save";
          "ctrl-f" = "buffer_search::Deploy";
          "ctrl-h" = "buffer_search::DeployReplace";
          "ctrl-/" = "editor::ToggleComments";
          "ctrl-d" = "editor::SelectNext";
          "ctrl-shift-d" = "editor::DuplicateLine";
          "alt-up" = "editor::MoveLineUp";
          "alt-down" = "editor::MoveLineDown";
        };
      }
    ];

    # VSCodium (from master via pkgsMaster)
    programs.vscode = {
      enable = true;
      package = pkgsMaster.vscodium;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          # Nix
          jnoortheen.nix-ide

          # Python
          charliermarsh.ruff
          detachhead.basedpyright

          # Rust
          rust-lang.rust-analyzer

          # Nix (additional)
          bbenoist.nix

          # Markdown
          yzhang.markdown-all-in-one

          # Git
          eamodio.gitlens

          # Themes
          enkia.tokyo-night
        ];

        userSettings = {
          # Theme
          "workbench.colorTheme" = "Tokyo Night";
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";

          # Nix
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${pkgs.nixd}/bin/nixd";

          # Python
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
          "python.analysis.typeCheckingMode" = "basic";

          # Rust
          "rust-analyzer.checkOnSave.command" = "clippy";
          "rust-analyzer.cargo.features" = "all";

          # General
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.detectIndentation" = false;
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "telemetry.telemetryLevel" = "off";
        };
      };
    };

    # Editor aliases - defined here since they're editor-specific
    home.shellAliases = {
      zed = "zeditor";
      code = "codium";
    };
  };
}

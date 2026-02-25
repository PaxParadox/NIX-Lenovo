# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

NixOS flake configuration for Lenovo E14 Gen 5 laptop (hostname: `lenovonix`). Uses flakes and home-manager to manage both system-level and user-level environments with a multi-channel package sourcing strategy.

## Architecture

### Multi-Channel Package Strategy
This configuration uses three nixpkgs channels simultaneously:
- **nixpkgs (25.11)**: Stable packages for system configuration
- **nixpkgs-unstable**: Newer packages with binary cache (gaming tools, editors)
- **nixpkgs-master**: Latest versions, may build from source (VSCodium, opencode, etc.)

Access via `pkgs`, `pkgsUnstable`, and `pkgsMaster` in configuration files through `specialArgs` and `extraSpecialArgs`.

**Important**: These are separate package sets, NOT overlays. This prevents dependency conflicts between channels. Use them like:
```nix
{ pkgs, pkgsUnstable, pkgsMaster, ... }: {
  home.packages = [
    pkgsUnstable.zed-editor
    pkgsMaster.vscodium
    pkgs.git
  ];
}
```

### Repository Structure
- `flake.nix`: Entry point, defines nixosConfigurations and homeConfigurations
- `hosts/lenovonix/`: System-level configuration (boot, networking, services, system packages)
- `home-manager/home.nix`: Main home-manager entry point (imports modules)
- `home-manager/modules/`: Modular user configurations
  - `core.nix`: Essential packages (always enabled)
  - `shells.nix`, `git.nix`, `editors.nix`, `terminal.nix`: Toggleable modules
  - `media.nix`, `browsers.nix`: Placeholder modules for future use
- `home-manager/archive/`: Backup of original configurations
- `secrets/`: Encrypted secrets managed by sops-nix

### Configuration Pattern
System configuration uses NixOS modules (services, programs) with home-manager integrated via `nixosModules.home-manager`. User configuration leverages home-manager's program modules (programs.vscode, programs.git, etc.) for declarative dotfile management.

## Build Commands

### System Deployment (requires sudo)
- Update system (from /etc/nixos): `sudo nixos-rebuild switch --flake /etc/nixos#lenovonix`
- Update system (from local repo): `sudo nixos-rebuild switch --flake .#lenovonix`

### System Build
- Dry-run (evaluate only): `nixos-rebuild dry-build --flake .#lenovonix`
- Build without switching: `nixos-rebuild build --flake .#lenovonix`
- Build using flake directly: `nix build .#nixosConfigurations.lenovonix.config.system.build.toplevel`

### Home-Manager Build
- Build user configuration: `home-manager build --flake .#paradox`
- Switch user configuration: `home-manager switch --flake .#paradox`
- Deploy from /etc/nixos: `home-manager switch --flake /etc/nixos#paradox`

### Flake Development
- Update flake inputs: `nix flake update`
- Show flake outputs: `nix flake show`
- Evaluate flake: `nix eval --json .`

## Lint Commands

### Format Checking
- **Format all files**: `nix fmt` (uses alejandra from flake.nix)
- Check formatting with alejandra: `alejandra --check .`
- Auto-format with alejandra: `alejandra .`

### Static Analysis
- Run statix for linting: `statix check`
- Apply statix suggestions: `statix fix`
- Evaluate flake for errors: `nix flake check`
- Run all checks: `nix flake check` (includes formatting, NixOS eval, home-manager eval)

### Nix Evaluation
- Evaluate all Nix files for syntax: `nix-instantiate --parse --eval -E 'import ./flake.nix'`
- Check for undefined variables: `nix eval --raw .`

## Test Commands

**Note**: This repository does not contain a traditional test suite. Configuration correctness is verified through:

- Dry-build evaluation: `nixos-rebuild dry-build --flake .#lenovonix`
- Home-manager build: `home-manager build --flake .#paradox`
- Manual testing after switching configurations

For unit testing of Nix expressions, consider using `nix-test` or `runCommand` checks.

## Code Style Guidelines

### Indentation and Formatting
- Use **2 spaces** per indentation level (no tabs)
- Line length: aim for 80 characters, but 100 is acceptable
- Trailing whitespace: never allowed
- File endings: Unix (LF)

### Naming Conventions
- Variables: `lowercase` with `hyphens` for multi-word names
- Attribute names: `lowercase-with-hyphens`
- Function parameters: `camelCase` or descriptive names (`pkgs`, `config`, `lib`, `options`)
- Derivation names: follow nixpkgs convention (`hello`, `python3Packages.numpy`)

### Imports and Structure
- List imports in an array, one per line, sorted alphabetically
- Use relative paths for local imports: `./hardware-configuration.nix`
- Reference nixpkgs via `pkgs` parameter
- Use `lib` for nixpkgs.lib utilities

### Function Definitions
- Use curly-brace argument sets: `{ config, pkgs, ... }:`
- Default arguments: `{ config, pkgs, lib, ... }:`
- Add `...` to allow extra arguments
- Place function argument on same line as opening brace

### Attribute Sets
- Use trailing commas for multi-line attribute sets
- Align equals signs within the same attribute set
- Group related attributes together (boot, networking, services)
- Use double quotes only for strings containing spaces or special characters

### Error Handling and Validation
- Use `assert` for runtime checks: `assert lib.assertMsg (condition) "message";`
- Use `lib.options.mkDefault` for optional defaults
- Use `builtins.tryEval` for safe evaluation
- Provide helpful error messages with `lib.throwIfNot`

### Comments
- Use `#` for single-line comments
- Multi-line comments: `/* ... */` (rarely needed)
- Comment complex logic and non-obvious choices
- Keep comments up-to-date with code changes

### Example Style

```nix
{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "lenovonix";
  environment.systemPackages = with pkgs; [ git ];
  users.users.paradox = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
```

## Nix-Specific Conventions

### Flake Structure
- Keep `flake.nix` minimal; delegate to modules and use `specialArgs`.

### Module System
- Use `lib.mkIf`, `lib.mkDefault`, `lib.mkForce` appropriately; define options with `lib.options.mkOption`.
- **NEVER use `with lib;` at the top level** - it causes scoping issues and makes grep/search impossible. Use explicit `lib.` prefixes instead.

### Package Management
- Prefer program modules (`programs.git.enable = true`) over manual package installation.

### Security
- Never hardcode secrets; use `sops-nix` for secret management
- See [Secrets Management](#secrets-management) section for setup instructions

## Common Operations (for Agents)

### Adding System Packages
1. Edit `hosts/lenovonix/configuration.nix`
2. Add package to `environment.systemPackages = with pkgs; [ ... ];`
3. Test with dry-build

### Adding User Packages

#### Option 1: Add to Core Module (Recommended for essential tools)
1. Edit `home-manager/modules/core.nix`
2. Add package to `home.packages` list
3. Run `home-manager build --flake .#paradox`

#### Option 2: Create a New Module (Recommended for feature groups)
1. Create new file in `home-manager/modules/` (e.g., `development.nix`)
2. Use the module template pattern with `mkEnableOption`
3. Import in `home-manager/home.nix`
4. Enable in `myModules` configuration
5. See [Home-Manager Modules](#home-manager-modules) section for details

### Creating New Host
1. Create directory `hosts/newhost/`
2. Generate hardware config: `sudo nixos-generate-config --dir hosts/newhost/`
3. Create `configuration.nix` based on existing template
4. Add entry to `flake.nix` under `nixosConfigurations`
5. Test with `nixos-rebuild dry-build --flake .#newhost`


## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes](https://nixos.wiki/wiki/Flakes)
- [Nixpkgs Style Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [Statix Documentation](https://github.com/nerdypepper/statix)
- [Alejandra](https://github.com/kamadorueda/alejandra)

## Git Workflow Guidelines

### Commit Strategy
Always commit logical changes separately rather than bundling unrelated changes:

**Do:**
```bash
# Commit 1: Add new feature
git add flake.nix
git commit -m "feat: add sops-nix for secrets management"

# Commit 2: Update documentation
git add AGENTS.md
git commit -m "docs: document sops-nix setup and usage"

# Commit 3: Fix formatting
git add hosts/lenovonix/configuration.nix
git commit -m "style: fix indentation in configuration"
```

**Don't:**
```bash
# Avoid bundling unrelated changes
git add .
git commit -m "various updates"
```

### Commit Message Format
Use conventional commits for clarity:
- `feat:` - New feature or capability
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style/formatting (no functional change)
- `refactor:` - Code restructuring (no functional change)
- `chore:` - Maintenance tasks, dependencies, etc.

### When to Commit
- After completing a logical unit of work
- Before switching to a different task
- After fixing a specific issue
- Before running potentially destructive commands

## Secrets Management

This repository uses **sops-nix** for secure secret management. Secrets are encrypted using age keys and can be safely committed to git.

### Quick Setup

1. **Generate age key:**
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. **Configure .sops.yaml:**
   ```yaml
   keys:
     - &admin_age <YOUR_PUBLIC_KEY>
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *admin_age
   ```

3. **Create and edit secrets:**
   ```bash
   sops secrets/secrets.yaml
   ```

4. **Use secrets in configuration:**
   ```nix
   sops.secrets.my-password = {
     sopsFile = ./secrets/secrets.yaml;
     key = "path.in.yaml";
   };
   ```

### Why sops-nix?

- **Secure**: Uses modern age encryption
- **Convenient**: Edit secrets with `sops` command
- **Flexible**: Supports YAML, JSON, binary, .env formats
- **Shareable**: Multiple keys can decrypt same secrets
- **Integrated**: Works with both NixOS and home-manager

### Important Security Notes

- **Never commit** `~/.config/sops/age/keys.txt` (private key)
- **Do commit** `.sops.yaml` (only contains public keys)
- **Do commit** encrypted secrets in `secrets/`
- Backup your age private key securely (password manager, encrypted USB)
- Use different keys for different machines when possible

### Common Operations

```bash
# Edit secrets
sops secrets/secrets.yaml

# View decrypted secrets
sops -d secrets/secrets.yaml

# Add new key for another machine
sops updatekeys secrets/secrets.yaml

# Rotate encryption keys
sops rotate -i secrets/secrets.yaml
```

### Example: WiFi Password

```yaml
# secrets/secrets.yaml
wifi:
  home:
    ssid: "MyNetwork"
    password: "super-secret-password"
```

```nix
# configuration.nix
networking.wireless.networks = {
  "MyNetwork".psk = config.sops.secrets.wifi-password.path;
};

sops.secrets.wifi-password = {
  sopsFile = ./secrets/secrets.yaml;
  key = "wifi.home.password";
};
```

See `secrets/README.md` for detailed documentation.

## Home-Manager Modules

This repository uses a modular home-manager structure for better organization and maintainability.

### Available Modules

| Module | Purpose | Always Enabled | Options |
|--------|---------|----------------|---------|
| `core.nix` | Essential packages and base config | Yes | None |
| `shells.nix` | Bash, fish, shell aliases | No | `enable`, `defaultShell` |
| `git.nix` | Git configuration | No | `enable` |
| `editors.nix` | Neovim, VS Code: | No | `enable`, `defaultEditor`, `vscode.theme`, `vscode.fontSize` |
| `terminal.nix` | Tmux, Ghostty | No | `enable`, `ghostty.fontSize`, `ghostty.theme` |
| `media.nix` | Media applications | No | `enable` (placeholder) |
| `browsers.nix` | Web browsers | No | `enable` (placeholder) |

### Module Configuration

Configure modules in `home-manager/home.nix`:

```nix
{
  myModules = {
    # Enable/disable modules
    shells.enable = true;
    git.enable = true;
    editors.enable = true;
    terminal.enable = true;
    media.enable = false;      # Disabled
    browsers.enable = false;   # Disabled
    
    # Customize options
    shells.defaultShell = "fish";  # "bash", "fish", or "none"
    
    editors = {
      defaultEditor = "nvim";      # "nvim", "vscode", or "none"
      vscode.theme = "Monokai";
      vscode.fontSize = 16;
    };
    
    terminal = {
      ghostty.fontSize = 12;
      ghostty.theme = "Builtin Solarized Dark";
    };
  };
}
```

### Creating a New Module

1. **Create module file** in `home-manager/modules/`:

```nix
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.newmodule;
in {
  options.myModules.newmodule = {
    enable = mkEnableOption "new module description";
    
    # Add custom options
    someOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "Description of this option";
    };
  };

  config = mkIf cfg.enable {
    # Module configuration here
    home.packages = [ pkgs.some-package ];
    
    programs.some-program = {
      enable = true;
      setting = cfg.someOption;
    };
  };
}
```

2. **Import in home.nix**:

```nix
{
  imports = [
    ./modules/core.nix
    ./modules/newmodule.nix  # Add here
  ];
}
```

3. **Enable and configure**:

```nix
{
  myModules.newmodule = {
    enable = true;
    someOption = "custom-value";
  };
}
```

### Per-Host Configuration

The modular structure supports per-host customization for multi-machine setups:

```nix
{ config, pkgs, lib, ... }:

let
  hostname = builtins.getEnv "HOSTNAME";
  isDesktop = hostname == "desktop";
  isLaptop = hostname == "lenovonix";
in {
  # Common configuration
  myModules.editors.enable = true;
  
  # Desktop-specific: larger fonts, more extensions
  myModules.editors.vscode.fontSize = lib.mkIf isDesktop 16;
  
  # Laptop-specific: battery-optimized settings
  home.packages = lib.mkIf isLaptop (with pkgs; [
    powertop
    tlp
  ]);
}
```

### Benefits of Modular Structure

1. **Organization**: Each module is 15-60 lines vs 176-line monolith
2. **Discoverability**: Easy to find specific configurations
3. **Flexibility**: Toggle modules on/off per host or use case
4. **Maintainability**: Changes are isolated to specific modules
5. **Testing**: Can test individual modules independently
6. **Collaboration**: Multiple people can work on different modules

### Module Template

Use this template for new modules:

```nix
# home-manager/modules/template.nix
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myModules.template;
in {
  options.myModules.template = {
    enable = mkEnableOption "template module";
  };

  config = mkIf cfg.enable {
    # Your configuration here
  };
}
```

---
*This file is intended for agentic coding assistants. Last updated: 2026-01-31*
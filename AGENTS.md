# Agent Guidelines for NIX-Lenovo Configuration

This repository contains NixOS flake configuration for the Lenovo E14 Gen 5 laptop. This document provides guidelines for agentic coding assistants working with this codebase, including build/lint/test commands and code style conventions.

## Build Commands

### System Build
- Dry-run (evaluate only): `nixos-rebuild dry-build --flake .#lenovonix`
- Build without switching: `nixos-rebuild build --flake .#lenovonix`
- Build using flake directly: `nix build .#nixosConfigurations.lenovonix.config.system.build.toplevel`

### Home-Manager Build
- Build user configuration: `home-manager build --flake .#paradox`
- Switch user configuration: `home-manager switch --flake .#paradox`

### Flake Development
- Update flake inputs: `nix flake update`
- Show flake outputs: `nix flake show`
- Evaluate flake: `nix eval --json .`

## Lint Commands

### Format Checking
- Check formatting with alejandra: `alejandra --check .`
- Auto-format with alejandra: `alejandra .`
- If nixfmt is configured: `nix fmt --check`

### Static Analysis
- Run statix for linting: `statix check`
- Apply statix suggestions: `statix fix`
- Evaluate flake for errors: `nix flake check`

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

### Package Management
- Prefer program modules (`programs.git.enable = true`) over manual package installation.

### Security
- Never hardcode secrets; use `age` or `sops-nix` for secret management.

## Common Operations (for Agents)

### Adding System Packages
1. Edit `hosts/lenovonix/configuration.nix`
2. Add package to `environment.systemPackages = with pkgs; [ ... ];`
3. Test with dry-build

### Adding User Packages
1. Edit `home-manager/paradox.nix`
2. Add package to `home.packages = with pkgs; [ ... ];`
3. Run `home-manager build --flake .#paradox`

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

---
*This file is intended for agentic coding assistants. Last updated: $(date)*
# NixOS Configuration for Lenovonix

This repository contains the NixOS flake configuration for the Lenovo E14 Gen 5 laptop (hostname `lenovonix`). It uses flakes and home-manager to manage both system and user environments.

## Repository Structure

- `flake.nix`: Main flake definition, imports system and home-manager configurations.
- `hosts/lenovonix/`: Host-specific configuration.
  - `configuration.nix`: System configuration (boot, networking, services, etc.)
  - `hardware-configuration.nix`: Auto-generated hardware config (do not edit manually).
- `home-manager/`: User-specific configuration.
  - `paradox.nix`: Home-manager configuration for user `paradox`.
- `AGENTS.md`: This file.

## Common Operations

### Updating the System

To update the system with the latest configuration:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#lenovonix
```

Alternatively, from the repository directory:

```bash
sudo nixos-rebuild switch --flake .#lenovonix
```

### Updating Home-Manager Only

If you only want to update the user environment (without rebuilding the whole system):

```bash
home-manager switch --flake /etc/nixos#paradox
```

### Adding System Packages

Edit `hosts/lenovonix/configuration.nix` and add packages to `environment.systemPackages`.

### Adding User Packages

Edit `home-manager/paradox.nix` and add packages to `home.packages`.

### Changing Git Configuration

Edit `home-manager/paradox.nix` and modify the `programs.git.settings` section.

### Adding a New Host

1. Create a new directory under `hosts/` (e.g., `hosts/newhost`).
2. Copy the existing `configuration.nix` and `hardware-configuration.nix` (generate with `nixos-generate-config`).
3. Add the new host to `flake.nix` by adding another entry in `nixosConfigurations`.
4. Update the symlink or set `NIXOS_CONFIG` accordingly.

### Adding a New User

1. Create a new file `home-manager/newuser.nix`.
2. Add a corresponding entry in `flake.nix` under `home-manager.users`.
3. Optionally add the user to `configuration.nix` `users.users`.

## Flake Inputs

- `nixpkgs`: Pinned to `nixos-25.11` branch.
- `home-manager`: Pinned to `release-25.11` branch.

To update the inputs, run:

```bash
nix flake update
```

Then rebuild the system.

## Troubleshooting

### Git Tree Dirty Warnings

If you see warnings about a dirty Git tree, commit your changes:

```bash
git add .
git commit -m "Update"
```

### Package Conflicts

If you encounter conflicts like `two given paths contain a conflicting subpath`, ensure you are not installing the same package both system-wide and via home-manager, or via both `home.packages` and a program module (e.g., `programs.neovim`).

### Option Rename Warnings

Some options may have been renamed in newer NixOS releases. Check the warning messages and update the configuration accordingly.

## Backup and Recovery

The previous configuration is backed up at `/etc/nixos.backup`. If the new configuration fails to boot, you can revert by:

```bash
sudo mv /etc/nixos /etc/nixos.broken
sudo mv /etc/nixos.backup /etc/nixos
sudo nixos-rebuild switch
```

## Useful Commands

- List current generations: `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`
- Rollback to previous generation: `sudo nixos-rebuild switch --rollback`
- Garbage collect old generations: `sudo nix-collect-garbage -d`
- Search for packages: `nix search nixpkgs#package-name`

## Notes

- The configuration uses the latest Linux kernel (`boot.kernelPackages = pkgs.linuxPackages_latest`).
- GNOME is the desktop environment.
- PipeWire is used for audio.
- Flakes and nix-command are enabled.

## Contributing

Commit messages should be descriptive. Keep the configuration modular and well-documented.

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes](https://nixos.wiki/wiki/Flakes)

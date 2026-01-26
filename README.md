# NIX-Lenovo
Nix config for my Lenovo E14 Gen 5

This repository contains the NixOS flake configuration for the Lenovo E14 Gen 5 laptop (hostname `lenovonix`). It uses flakes and home-manager to manage both system and user environments.

## Quick Start

- Update system: `sudo nixos-rebuild switch --flake /etc/nixos#lenovonix`
- Update home-manager only: `home-manager switch --flake /etc/nixos#paradox`

See [AGENTS.md](AGENTS.md) for detailed documentation.

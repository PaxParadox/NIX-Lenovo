# SOPS Configuration

This directory contains encrypted secrets managed by sops-nix.

## Structure

```
secrets/
├── secrets.yaml          # Main secrets file (encrypted)
├── .sops.yaml            # SOPS configuration (public keys)
└── README.md             # This file
```

## Setup Instructions

### 1. Generate Age Key

```bash
# Create directory for age keys
mkdir -p ~/.config/sops/age

# Generate new key
age-keygen -o ~/.config/sops/age/keys.txt

# Get your public key
cat ~/.config/sops/age/keys.txt | grep "public key"
```

### 2. Configure .sops.yaml

Create `.sops.yaml` in the repository root:

```yaml
keys:
  - &admin_age <YOUR_PUBLIC_KEY_HERE>

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *admin_age
```

Replace `<YOUR_PUBLIC_KEY_HERE>` with your actual age public key (starts with `age1...`).

### 3. Create and Edit Secrets

```bash
# Create new secrets file
sops secrets/secrets.yaml

# This opens your $EDITOR with a YAML structure
# Add secrets like:
# api_key: "super-secret-api-key"
# password: "my-password"
```

### 4. Use Secrets in Configuration

In your NixOS or home-manager configuration:

```nix
{ config, ... }:

{
  # Reference a secret
  services.some-service.passwordFile = config.sops.secrets.api-key.path;
  
  # Or use in templates
  sops.templates."my-config".content = ''
    API_KEY=${config.sops.placeholder.api-key}
  '';
}
```

## Adding More Keys

To allow multiple people/machines to decrypt:

1. Add their public keys to `.sops.yaml`:

```yaml
keys:
  - &admin_age <ADMIN_PUBLIC_KEY>
  - &laptop_age <LAPTOP_PUBLIC_KEY>
  - &server_age <SERVER_PUBLIC_KEY>

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *admin_age
          - *laptop_age
          - *server_age
```

2. Re-encrypt existing secrets:

```bash
sops updatekeys secrets/secrets.yaml
```

## Common Commands

```bash
# Edit secrets
sops secrets/secrets.yaml

# View secrets (decrypt to stdout)
sops -d secrets/secrets.yaml

# Rotate data keys (re-encrypt with new keys)
sops rotate -i secrets/secrets.yaml

# Validate configuration
sops --config .sops.yaml --validate
```

## Security Notes

- **Never commit** the age private key (`~/.config/sops/age/keys.txt`)
- **Do commit** `.sops.yaml` (it only contains public keys)
- Encrypted secrets are safe to commit to git
- Always backup your age private key securely
- Use different keys for different machines/users when possible

## Example: WiFi Password

```yaml
# secrets/secrets.yaml
wifi:
  home:
    ssid: "MyHomeNetwork"
    password: "super-secret-wifi-password"
```

```nix
# In configuration.nix
networking.wireless.networks = {
  "MyHomeNetwork".psk = config.sops.secrets.wifi-home-password.path;
};

sops.secrets.wifi-home-password = {
  sopsFile = ./secrets/secrets.yaml;
  path = "/run/secrets/wifi-password";
  format = "yaml";
  key = "wifi.home.password";
};
```

## References

- [sops-nix documentation](https://github.com/Mic92/sops-nix)
- [Mozilla SOPS](https://github.com/getsops/sops)
- [age encryption](https://age-encryption.org/)

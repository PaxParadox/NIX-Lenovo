# Lenovo E14 Gen 5 laptop configuration
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/base.nix
    ../common/hyprland.nix
    inputs.sops-nix.nixosModules.sops
  ];

  networking.hostName = "lenovonix";

  # Allow insecure packages (ventoy)
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];

  # Intel integrated graphics (Iris Xe)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  # Power management for lid/suspend
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  # Fingerprint reader (Goodix 550a)
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix-550a;
    };
  };

  # PAM fingerprint authentication
  security.pam.services.sddm.fprintAuth = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = lib.mkForce true;

  # System packages (laptop-specific)
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    ventoy
    gnome-disk-utility
  ];

  # SOPS secrets
  sops = {
    age.keyFile = "/home/paradox/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
  };
}

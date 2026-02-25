# Common base configuration for all hosts
# Shared settings: bootloader, networking, locale, basic services
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./users.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use stable kernel (not latest)
  # Latest kernel causes issues with sleep/resume on some hardware

  # Hostname is set per-host

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Berlin";

  # DNS resolution
  services.resolved.enable = true;

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchpad support
  services.libinput.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.extra-experimental-features = ["nix-command" "flakes"];

  # System packages (minimal, most in home-manager)
  environment.systemPackages = with pkgs; [
    wget
    git
    home-manager
  ];

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-dns"
    ];
  };

  # Tailscale firewall
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [41641];
  };

  # Restart Tailscale after resume from sleep
  systemd.services.tailscale-resume = {
    description = "Restart Tailscale after resume";
    wantedBy = ["suspend.target" "hibernate.target"];
    after = ["suspend.target" "hibernate.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tailscale}/bin/tailscale down && ${pkgs.tailscale}/bin/tailscale up";
      User = "root";
    };
  };

  # System state version
  system.stateVersion = "25.11";
}

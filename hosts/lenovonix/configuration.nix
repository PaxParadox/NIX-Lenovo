# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgsUnstable,
  inputs,
  kimi-cli,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Import sops-nix module for secrets management
    inputs.sops-nix.nixosModules.sops
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lenovonix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system (needed for XWayland).
  services.xserver.enable = true;

  # Display Manager: SDDM for KDE Plasma
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Desktop Environment: KDE Plasma 6
  services.desktopManager.plasma6 = {
    enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support for laptop
  services.libinput.enable = true;

  # Enable fingerprint reader service with Goodix 550a driver
  services.fprintd = {
    enable = true;
    # Use fprintd-tod which supports TOD (Touch OEM Driver) backends
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix-550a;
    };
  };

  # Configure PAM for fingerprint authentication
  # Allows fingerprint OR password for login, sudo, and lock screen
  security.pam.services.sddm.fprintAuth = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  # Force override KDE's default (which disables fingerprint)
  security.pam.services.kde.fprintAuth = lib.mkForce true;

  # XDG Desktop Portal configuration
  # KDE Plasma provides its own portal (xdg-desktop-portal-kde)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    # Plasma portal is automatically added when plasma6 is enabled
  };

  # Polkit authentication agent (for GUI elevation requests)
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Enable dbus for notifications and other services
  services.dbus.enable = true;

  # Enable Flatpak for sandboxed app distribution
  services.flatpak.enable = true;

  # Fonts (Nerd Fonts for terminal icons)
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paradox = {
    isNormalUser = true;
    description = "Paradox";
    extraGroups = ["networkmanager" "wheel" "bluetooth"];
  };

  # Install firefox (latest from unstable).
  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;

  # Enable KDE Connect (native with KDE Plasma)
  programs.kdeconnect.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages (ventoy)
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.wget
    pkgs.bitwarden-desktop
    # Home Manager CLI tool
    pkgs.home-manager
    # Gaming packages from unstable (better cache, newer versions)
    pkgsUnstable.protonplus
    pkgsUnstable.bottles
    pkgsUnstable.mangohud
    # Kimi Code CLI - AI coding assistant
    kimi-cli.packages.${pkgs.system}.kimi-cli

    # Qt platform plugins for Wayland
    pkgs.qt5.qtwayland
    pkgs.qt6.qtwayland

    # KDE System Packages
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.gwenview
    pkgs.kdePackages.okular
    pkgs.kdePackages.kcharselect
    pkgs.kdePackages.ark
    pkgs.kdePackages.kio-fuse
    pkgs.kdePackages.kio-extras
    pkgs.kdePackages.bluedevil
    pkgs.bluez

    # Authentication agent (polkit)
    pkgs.kdePackages.polkit-kde-agent-1

    # Flatpak CLI tools
    pkgs.flatpak

    # Ventoy - bootable USB creator (GUI: VentoyGUI)
    pkgs.ventoy

    # GNOME Disks utility for drive formatting
    pkgs.gnome-disk-utility
  ];

  nix.settings.extra-experimental-features = ["nix-command" "flakes"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Gaming configuration
  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable Tailscale VPN.
  services.tailscale.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It 's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  # SOPS secrets management configuration
  # See secrets/README.md for setup instructions
  sops = {
    # Default age key location
    age.keyFile = "/home/paradox/.config/sops/age/keys.txt";

    # Default secrets file
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Example secret (uncomment after setting up secrets.yaml):
    # secrets.wifi-password = {
    #   # Key path in secrets.yaml (e.g., wifi.home.password)
    #   key = "wifi.home.password";
    #   # Where to place the decrypted secret
    #   path = "/run/secrets/wifi-password";
    # };

    # Example with template (for config files with embedded secrets):
    # templates."my-app-config".content = ''
    #   api_key = "${config.sops.placeholder.api-key}"
    #   db_password = "${config.sops.placeholder.db-password}"
    # '';
  };
}

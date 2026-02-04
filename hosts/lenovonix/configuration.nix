# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgsUnstable,
  inputs,
  kimi-cli,
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

  # Display Manager: GDM supports both GNOME and Hyprland
  # To switch to Hyprland-only with SDDM, see commented section below
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Desktop Environments
  # Keep GNOME enabled for dual-DE setup
  # If you experience issues, set services.desktopManager.gnome.enable = false
  services.desktopManager.gnome.enable = true;

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    package = pkgsUnstable.hyprland;
    xwayland.enable = true;
  };

  # Alternative: SDDM (uncomment to use instead of GDM)
  # Note: Disable GDM above before enabling this
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   theme = "where_is_my_sddm_theme";
  # };
  # services.desktopManager.gnome.enable = false;

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

  # Enable touchpad support for laptop and Hyprland
  services.libinput.enable = true;

  # XDG Desktop Portal configuration for Hyprland
  # This enables screen sharing, file opening, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgsUnstable.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ pkgsUnstable.hyprland ];
  };

  # Polkit authentication agent (for GUI elevation requests)
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Enable dbus for notifications and other services
  services.dbus.enable = true;

  # Fonts for Hyprland (Nerd Fonts for icons in waybar)
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paradox = {
    isNormalUser = true;
    description = "Paradox";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

    # Hyprland system utilities
    pkgsUnstable.hyprland
    pkgsUnstable.hyprlock
    pkgsUnstable.hypridle
    pkgsUnstable.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
    pkgsUnstable.grimblast
    pkgsUnstable.wl-clipboard
    pkgs.brightnessctl
    pkgs.playerctl

    # Qt platform plugins for Wayland
    pkgs.qt5.qtwayland
    pkgs.qt6.qtwayland

    # Authentication agent (polkit)
    pkgs.polkit_gnome
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

# Hyprland desktop environment configuration
# Shared across all hosts
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Display Manager: SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Desktop Environment: Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Desktop Portal for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    configPackages = [pkgs.hyprland];
  };

  # Polkit authentication agent
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Enable dbus
  services.dbus.enable = true;

  # Enable X11 (for XWayland)
  services.xserver.enable = true;

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # System packages for Hyprland
  environment.systemPackages = with pkgs; [
    # SDDM theme
    kdePackages.breeze

    # Qt platform plugins for Wayland
    qt5.qtwayland
    qt6.qtwayland

    # Polkit agent
    polkit_gnome

    # Notification daemon
    mako
    libnotify

    # Clipboard manager
    wl-clipboard

    # Screenshot tool
    grim
    slurp

    # Screen locker
    hyprlock

    # Idle management
    hypridle

    # Wallpapers
    swww

    # File manager (Thunar)
    xfce.thunar
  ];
}

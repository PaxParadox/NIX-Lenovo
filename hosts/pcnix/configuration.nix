# Desktop PC configuration (NVIDIA + Gaming)
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

  networking.hostName = "pcnix";

  # NVIDIA drivers
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  # Gaming packages
  environment.systemPackages = with pkgs; [
    protonplus
    bottles
    mangohud
  ];

  # SOPS secrets
  sops = {
    age.keyFile = "/home/paradox/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
  };
}

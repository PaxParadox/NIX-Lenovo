# Hardware configuration for pcnix
# WARNING: This is a TEMPLATE file. You need to generate the real one:
#   sudo nixos-generate-config --dir /etc/nixos/hosts/pcnix
# Then copy hardware-configuration.nix here and commit.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd" "kvm-intel"];
  boot.extraModulePackages = [];

  # WARNING: REPLACE THESE WITH YOUR ACTUAL DISK UUIDs
  # Run: lsblk -f  to find your UUIDs
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ME";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-ME";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/REPLACE-ME";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

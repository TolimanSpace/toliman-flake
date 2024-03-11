{ config, lib, pkgs, ... }:

{
  imports = [ ./software ./state-version.nix ];

  # Enable Anduril's Jetpack modules
  hardware.nvidia-jetpack = {
    enable = true;
    som = "xavier-nx-emmc";
    carrierBoard = "devkit"; # devkit enables fan control
  };

  # Shared bootloader config, specifies
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Shared kernel modules
  boot.initrd.availableKernelModules = [ "nvme" "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Jetsons are all aarch64-linux
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Required "experimental" features enabled
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
}

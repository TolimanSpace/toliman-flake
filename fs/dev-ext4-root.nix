{ config, lib, pkgs, ... }:

{
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}

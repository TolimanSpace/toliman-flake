{ config, lib, pkgs, ... }:

{
  imports = [ ];

  # Set hostname
  networking.hostName = "toliman-dev";

  # Enable networkmanager. On the production device, you may want to not use this,
  # hence it being declared separately in dev.
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  users = {
    mutableUsers = true; # You can manually modify user stuff, e.g. the passwd command
    users = {
      toliman = {
        isNormalUser = true;
        createHome = true; # Automatically create a home directory for the user
        home = "/home/toliman";
        extraGroups = [ "wheel" "networkmanager" "docker" "flirimaging" ];
      };
    };
  };
  
  # spinaker/flir udev rules
  services.udev.extraRules = "
  SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1e10\", GROUP=\"flirimaging\"
  SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1724\", GROUP=\"flirimaging\"
";

  # spinaker usbfs requirments
  boot.kernelParams = [ "usbcore.usbfs_memory_mb=1000" ];

  # Dev software
  environment.systemPackages = with pkgs; [
    # Some handy utils
    vim
    wget
    curl
    tmux
    pv
    nload
    htop
    git
    jq
    usbutils
    ncdu
    pciutils
    ripgrep
    minicom

    spinnaker.spinnaker
    spinnaker.spin-video
    spinnaker.spin-update
    spinnaker.spinnaker-python310

    spinnaker-acquisition

    python310Packages.python
    python310Packages.pip

    # Alias for conveniently rebuilding the system.
    (pkgs.writeShellScriptBin "remote-switch" ''
      HOSTNAME=$(cat /etc/hostname) &&
      FLAKE_URL="github:TolimanSpace/toliman-flake#$HOSTNAME" &&
      sudo nixos-rebuild switch --refresh -L -v --flake $FLAKE_URL
    '')
  ];

  environment.variables = {
    SPINNAKER_GENTL64_CTI = pkgs.spinnaker.spinnaker-cti-path;
  };

  # Enable ssh
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
  };
  services.tailscale.enable = true;
}

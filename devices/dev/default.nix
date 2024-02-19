{ config, lib, pkgs, ... }:

{
  imports = [ ];

  # Enable networkmanager. On the production device, you may want to not use this,
  # hence it being declared separately in dev.
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

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

    python310Packages.python
    python310Packages.pip

    # Alias for conveniently rebuilding the system.
    (pkgs.writeShellScriptBin "remote-switch" ''
      HOSTNAME=$(cat /etc/hostname) \
      FLAKE_URL=github:foo/bar#$HOSTNAME \
      sudo nixos-rebuild switch -L -v --flake $FLAKE_URL
    '')
  ];

  environment.variables = {
    SPINNAKER_GENTL64_CTI = pkgs.spinnaker-cti-path;
  };

  # Enable ssh
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
  };
}

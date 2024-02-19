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

    # Alias for conveniently rebuilding the system.
    (pkgs.writeShellScriptBin "remote-switch" ''
      HOSTNAME=$(cat /etc/hostname) \
      FLAKE_URL=github:foo/bar#$HOSTNAME \
      sudo nixos-rebuild switch -L -v --flake $FLAKE_URL
    '')
  ];

  # Enable ssh
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
  };
}

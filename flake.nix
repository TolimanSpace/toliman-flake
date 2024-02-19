{
  description = "NixOS flake for Toliman";

  inputs = {
    # NixOS 23.11
    # Avoid changing it in production, but changing before production is ok
    nixpkgs.url = "nixpkgs/nixos-23.11";

    # Anduril's modules for running NixOS on the Jetson
    jetpack-nixos = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jetpack-nixos, ... }@inputs:
    with inputs;
    let
      lib = nixpkgs.lib;
      system = "aarch64-linux";
    in
    {
      nixosConfigurations.toliman-dev = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./shared
          ./devices/dev
          jetpack-nixos.nixosModules.default
        ];
      };

      nixosConfigurations.toliman-prod-teser = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./shared
          ./devices/prod-tester
          jetpack-nixos.nixosModules.default
        ];
      };
    };
}

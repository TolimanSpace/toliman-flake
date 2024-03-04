{
  description = "NixOS flake for Toliman";

  inputs = {
    # NixOS 23.11
    # Avoid changing it in production, but changing before production is ok
    nixpkgs.url = "github:NixOS/nixpkgs?rev=a77ab169a83a4175169d78684ddd2e54486ac651";

    vscode-server={
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Anduril's modules for running NixOS on the Jetson
    jetpack-nixos = {
      url = "github:anduril/jetpack-nixos?rev=d9d1398b35dbe206b615d646a98b43f5b79c0c87";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jetpack-nixos, vscode-server, ... }@inputs:
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
          ./fs/dev-ext4-root.nix
          jetpack-nixos.nixosModules.default
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
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
          # TODO: Add drive mappings
          jetpack-nixos.nixosModules.default
        ];
      };
    };
}

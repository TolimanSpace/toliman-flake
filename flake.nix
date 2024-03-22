{
  description = "NixOS flake for Toliman";

  inputs = {
    # NixOS 23.11
    # Avoid changing it in production, but changing before production is ok
    nixpkgs.url = "github:arduano/nixpkgs?rev=e92019587048d3c2c2cc59875a3e0b40f7680d93";

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Anduril's modules for running NixOS on the Jetson
    jetpack-nixos = {
      url = "github:anduril/jetpack-nixos?rev=d9d1398b35dbe206b615d646a98b43f5b79c0c87";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, jetpack-nixos, vscode-server, flake-utils, ... }@inputs:
    with inputs;
    let
      lib = nixpkgs.lib;
      system = "aarch64-linux";

      systems = {
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

      packages =
        flake-utils.lib.eachDefaultSystem
          (system:
            let
              pkgs = import nixpkgs {
                inherit system;
                overlays = [ (import ./shared/software/overlay.nix) ];
              };
            in
            {
              packages = pkgs.toliman;
            }
          );
    in
    systems // packages;
}

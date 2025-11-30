{
  description = "nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell/?ref=v0.6.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
  };

  outputs = { nixpkgs, agenix, home-manager, dankMaterialShell, niri, nix-index-database, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations = {
        az-pve = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home/az-pve.nix
            nix-index-database.homeModules.nix-index
          ];
        };
        zx = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home/zx.nix
            nix-index-database.homeModules.nix-index
            dankMaterialShell.homeModules.dankMaterialShell.default
            dankMaterialShell.homeModules.dankMaterialShell.niri
            niri.homeModules.niri
            { 
              nixpkgs.overlays = [ niri.overlays.niri ];
            }
          ];
        };
      };

      nixosConfigurations = {

        tailscale-router = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./node/tailscale-router
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.nix-index
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.root = ./home/tailscale-router.nix;
            }
          ];
        };

        docker-stable = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./node/docker-stable
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.nix-index
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.root = ./home/docker-stable.nix;
            }
          ];
        };

        test-desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./node/test-desktop
            ./node/test-desktop/overlay.nix
            agenix.nixosModules.default
            nix-index-database.nixosModules.nix-index
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            dankMaterialShell.nixosModules.greeter
            niri.nixosModules.niri
          ];
        };
      };
    };
}

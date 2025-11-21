{
  description = "nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/?ref=v3.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { nixpkgs, agenix, home-manager, noctalia, niri,  nix-index-database, nix-flatpak, ... }:
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
            noctalia.homeModules.default
            niri.homeModules.niri
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
          ];
        };
      };
    };
}

{
  description = "nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
  };

  outputs = { nixpkgs, agenix, home-manager, nix-index-database, ... }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations.pve = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home/pve.nix
          nix-index-database.hmModules.nix-index
        ];
      };

      nixosConfigurations = {

        sandbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./node/sandbox
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.nix-index
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.root = ./home/sandbox.nix;
            }
          ];
        };
      };
    };
}

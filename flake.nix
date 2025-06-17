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
  };

  outputs = { nixpkgs, home-manager, nix-index-database, ... }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations.pve = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home.nix
          nix-index-database.hmModules.nix-index
        ];
      };
      homeConfigurations.sandbox = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./node/test/home.nix
          nix-index-database.hmModules.nix-index
          {
            home.sessionVariables.HOST0 = "$(cat /etc/hostname)";
            home.sessionVariables.HOST = "$(cat /etc/hostname)";
          }
        ];
      };

      nixosConfigurations.sandbox = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./node/test/config.nix
          nix-index-database.nixosModules.nix-index
        ];
      };
    };
}

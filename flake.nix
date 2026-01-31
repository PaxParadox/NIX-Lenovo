{
  description = "NixOS configuration for Lenovo E14 Gen 5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    pkgsUnstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsMaster = import inputs.nixpkgs-master {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.lenovonix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs pkgsUnstable;};
      modules = [
        ./hosts/lenovonix/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = false;
          home-manager.users.paradox = import ./home-manager/paradox.nix;
          home-manager.extraSpecialArgs = {inherit inputs pkgsUnstable pkgsMaster;};
        }
      ];
    };

    homeConfigurations.paradox = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [./home-manager/paradox.nix];
      extraSpecialArgs = {inherit inputs pkgsUnstable pkgsMaster;};
    };
  };
}

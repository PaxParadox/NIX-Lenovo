{
  description = "NixOS configuration for Lenovo E14 Gen 5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
          url = "github:nix-community/nix-vscode-extensions";
          inputs.nixpkgs.follows = "nixpkgs";
        };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
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
      overlays = [ nix-vscode-extensions.overlays.default ];
    };
    vscodeOverlay = nix-vscode-extensions.overlays.default;
  in {
    nixosConfigurations.lenovonix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs pkgsUnstable;};
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [ vscodeOverlay ];
        }
        ./hosts/lenovonix/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = false;
          home-manager.users.paradox = import ./home-manager/paradox.nix;
          home-manager.extraSpecialArgs = {inherit inputs pkgsUnstable;};
        }
      ];
    };

    homeConfigurations.paradox = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ vscodeOverlay ];
      };
      modules = [./home-manager/paradox.nix];
      extraSpecialArgs = {inherit inputs pkgsUnstable;};
    };
  };
}

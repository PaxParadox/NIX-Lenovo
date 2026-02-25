{
  description = "NixOS configuration for Lenovo E14 Gen 5 and Desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kimi-cli = {
      url = "github:MoonshotAI/kimi-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-master,
    home-manager,
    sops-nix,
    kimi-cli,
    zen-browser,
    ...
  }: let
    system = "x86_64-linux";

    # Base nixpkgs configuration
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Unstable package set - for packages needing newer versions
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Master package set - for bleeding-edge packages
    pkgsMaster = import nixpkgs-master {
      inherit system;
      config.allowUnfree = true;
    };

    # Overlay for flake-provided packages only
    # These are packages NOT in nixpkgs, so no dependency conflicts
    overlays = [
      (final: prev: {
        kimi-cli = kimi-cli.packages.${system}.kimi-cli;
        zen-browser = zen-browser.packages.${system}.default;
      })
    ];

    # Apply overlay to base pkgs
    pkgsWithOverlays = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    # Construct inputs attrset for modules that need it (sops-nix, etc.)
    inputs = {
      inherit sops-nix;
    };

    # Common special args for all configurations
    specialArgs = {
      inherit inputs pkgsUnstable pkgsMaster;
    };

    # Common home-manager special args
    extraSpecialArgs = {
      inherit pkgsUnstable pkgsMaster;
    };

    # Common home-manager module configuration
    homeManagerModule = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.paradox = import ./home-manager/home.nix;
      home-manager.extraSpecialArgs = extraSpecialArgs;
    };
  in {
    # Laptop configuration (lenovonix)
    nixosConfigurations.lenovonix = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        {nixpkgs.overlays = overlays;}
        ./hosts/lenovonix/configuration.nix
        home-manager.nixosModules.home-manager
        homeManagerModule
      ];
    };

    # Desktop configuration (pcnix)
    nixosConfigurations.pcnix = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        {nixpkgs.overlays = overlays;}
        ./hosts/pcnix/configuration.nix
        home-manager.nixosModules.home-manager
        homeManagerModule
      ];
    };

    # Standalone home-manager configuration
    homeConfigurations.paradox = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsWithOverlays;
      modules = [./home-manager/home.nix];
      extraSpecialArgs = extraSpecialArgs;
    };

    # Formatter for nix fmt
    formatter.${system} = pkgs.alejandra;

    # Checks for nix flake check
    checks.${system} = {
      # Verify lenovonix configuration evaluates correctly
      lenovonix-config =
        (nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            {nixpkgs.overlays = overlays;}
            ./hosts/lenovonix/configuration.nix
          ];
        })
        .config
        .system
        .build
        .toplevel;

      # Verify pcnix configuration evaluates correctly
      pcnix-config =
        (nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            {nixpkgs.overlays = overlays;}
            ./hosts/pcnix/configuration.nix
          ];
        })
        .config
        .system
        .build
        .toplevel;

      # Verify home-manager configuration evaluates correctly
      home-config =
        (home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsWithOverlays;
          modules = [./home-manager/home.nix];
          extraSpecialArgs = extraSpecialArgs;
        })
        .activationPackage;

      # Verify formatting is correct
      formatting =
        pkgs.runCommand "check-formatting"
        {
          nativeBuildInputs = [pkgs.alejandra];
        }
        ''
          alejandra --check ${./.}
          touch $out
        '';
    };
  };
}

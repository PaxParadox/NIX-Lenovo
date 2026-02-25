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
    home-manager,
    sops-nix,
    kimi-cli,
    zen-browser,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Overlays to pull specific packages from different channels
    overlays = [
      (final: prev: {
        # From unstable
        zed-editor = inputs.nixpkgs-unstable.legacyPackages.${system}.zed-editor;

        # From master
        vscodium = inputs.nixpkgs-master.legacyPackages.${system}.vscodium;
        opencode = inputs.nixpkgs-master.legacyPackages.${system}.opencode;

        # From flake inputs
        kimi-cli = inputs.kimi-cli.packages.${system}.kimi-cli;
        zen-browser = inputs.zen-browser.packages.${system}.default;
      })
    ];

    # Base nixpkgs configuration with overlays
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    # Common special args for all configurations
    specialArgs = {inherit inputs;};

    # Common home-manager special args
    extraSpecialArgs = {inherit inputs;};

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
      inherit pkgs;
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
          inherit pkgs;
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

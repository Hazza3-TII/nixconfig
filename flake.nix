{
  description = "sifr is a declarative system configuration built by Humaid";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs @ {
    self,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    nixos-generators,
    sops-nix,
    nur,
    alejandra,
    nix-darwin,
    deploy-rs,
    ...
  }: let
    vars = {
      user = "hazaa";
    };
    mksystem = import ./lib/mksystem.nix {
      inherit (nixpkgs) lib;
      inherit nixpkgs nixpkgs-unstable home-manager alejandra sops-nix nixos-generators nix-darwin;
    };
  in {
    # System Configurations for NixOS
    nixosConfigurations = {
      # System that runs on a VM on Macbook Pro, my main system
      goral = mksystem.nixosSystem "goral" {
        inherit vars;
        system = "aarch64-linux";
      };

      # Sytem that runs on Thinkpad T590
      serow = mksystem.nixosSystem "serow" {
        inherit vars;
        system = "x86_64-linux";
      };
      hazaa = mksystem.nixosSystem "hazaa" {
        inherit vars;
        system = "x86_64-linux";
      };

      # System that runs on Vultr cloud, hosting huma.id
      duisk = mksystem.nixosSystem "duisk" {
        inherit vars;
        system = "x86_64-linux";
      };

      # System that runs on my work laptop
      tahr = mksystem.nixosSystem "tahr" {
        inherit vars;
        system = "x86_64-linux";
      };

      # System that runs on my temporary Dell laptop
      capra = mksystem.nixosSystem "capra" {
        inherit vars;
        system = "x86_64-linux";
      };
    };


    # System Configurations for macOS
    darwinConfigurations = {
      takin = mksystem.darwinSystem "takin" {
        inherit vars;
      };
    };

    # Deployment
    deploy.nodes = {
      duisk = {
        hostname = "duisk";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.duisk;
        };
      };
      goral = {
        hostname = "goral";
        sudo = "doas -u";
        user = "${vars.user}";
        profiles.system = {
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.goral;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    # Generators for x86_64
    packages.x86_64-linux = let
      system = "x86_64-linux";
    in {
      x86-installer = mksystem.nixosGenerate "x86-installer" {
        inherit vars system;
        customFormats.standalone-iso = import ./lib/standalone-iso.nix {inherit nixpkgs;};
        format = "standalone-iso";
      };
      x86-docker = mksystem.nixosGenerate "x86-docker" {
        inherit vars system;
        format = "docker";
      };
    };

    # Generators for aarch64
    packages.aarch64-linux = let
      system = "aarch64-linux";
    in {
      aarch64-installer = mksystem.nixosGenerate "aarch64-installer" {
        inherit vars system;
        customFormats.standalone-iso = import ./lib/standalone-iso.nix {inherit nixpkgs;};
        format = "standalone-iso";
      };
      argali = mksystem.nixosGenerate "argali" {
        inherit vars system;
        format = "sd-aarch64";
        extraModules = [
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
      aarch64-dev-docker = mksystem.nixosGenerate "aarch64-dev-docker" {
        inherit vars system;
        format = "docker";
      };
    };
  };
}

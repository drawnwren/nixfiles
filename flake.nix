{
  description = "NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    render-markdown-nvim = {
      flake = false;
      url = "github:MeanderingProgrammer/render-markdown.nvim";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
    claude-code.inputs.nixpkgs.follows = "nixpkgs";

    codex-cli-nix.url = "github:colonelpanic8/codex-cli-nix/fix/add-libcap-to-rpath";
    codex-cli-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    nixpkgs,
    darwin,
    agenix,
    nixos-hardware,
    home-manager,
    ...
  }: let
    allowUnfreeModule = {
      nixpkgs.config.allowUnfree = true;
    };
    agenixPackageModule = system: {
      environment.systemPackages = [agenix.packages.${system}.default];
    };
    homeManagerCommonConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        repos = inputs;
      };
    };
  in {
    nixosConfigurations = {
      enki = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          allowUnfreeModule
          ./hosts/enki/configuration.nix
          ./services/wgnord.nix
          nixos-hardware.nixosModules.common-hidpi
          nixos-hardware.nixosModules.common-gpu-nvidia-sync
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          agenix.nixosModules.default
          (agenixPackageModule system)
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          homeManagerCommonConfig
          {
            home-manager.users.barbatos = {
              imports = [
                ./home.nix
                ./hosts/enki/home.nix
              ];
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      enlil = darwin.lib.darwinSystem rec {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          allowUnfreeModule
          ./hosts/enlil/configuration.nix
          agenix.darwinModules.default
          (agenixPackageModule system)
          inputs.stylix.darwinModules.stylix
          home-manager.darwinModules.home-manager
          homeManagerCommonConfig
          {
            home-manager.users.drew = {
              imports = [
                ./home.nix
                ./hosts/enlil/home.nix
              ];
            };
          }
        ];
      };
    };
  };
}

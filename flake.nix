{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    ghostty-hm-module.url = "github:clo4/ghostty-hm-module";
    catppuccin.url = "github:catppuccin/nix";
    codecompanion-nvim = {
      flake = false;
      url = "github:olimorris/codecompanion.nvim";
    };
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    supermaven = {
      flake = false;
      url = "github:supermaven-inc/supermaven-nvim";
    };
    render-markdown-nvim = {
      flake = false;
      url = "github:MeanderingProgrammer/render-markdown.nvim";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    catppuccin,
    darwin,
    agenix,
    nixos-hardware,
    home-manager,
    ghostty,
    ghostty-hm-module,
    flake-utils,
    ...
  }:
  let

    # Helper function for common home-manager configuration
    mkHomeManagerConfig = pkgs: extraModules: {
      imports = [./home.nix catppuccin.homeManagerModules.catppuccin] ++ extraModules;
    };

    # Shared home-manager configuration
    homeManagerCommonConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        repos = inputs;
      };
    };
    in
    {
      nixosConfigurations = {
        enki = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [
            ./hosts/enki/configuration.nix
            ./services/wgnord.nix
            nixos-hardware.nixosModules.common-hidpi
            nixos-hardware.nixosModules.common-gpu-nvidia-sync
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            agenix.nixosModules.default
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            homeManagerCommonConfig
            {
              home-manager.users.barbatos = mkHomeManagerConfig nixpkgs [];
            }
          ];
        };
      };
      
      darwinConfigurations = {
        enlil = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs;};
          modules = [./hosts/enlil/configuration.nix];
        };
      };
    };
}

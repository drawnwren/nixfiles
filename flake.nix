{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    catppuccin.url = "github:catppuccin/nix";
    catppuccin-nvim = { flake = false; url = "github:catppuccin/nvim"; };
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    supermaven = { flake = false; url = "github:supermaven-inc/supermaven-nvim"; };
    avante = { flake = false; url = "github:yetone/avante.nvim"; };
    render-markdown-nvim = { flake = false; url = "github:MeanderingProgrammer/render-markdown.nvim"; };
  };

  outputs = inputs@{ self, nixpkgs, catppuccin, catppuccin-nvim, agenix, nixos-hardware, home-manager, ... }: {
    nixosConfigurations = {
      enki = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./services/wgnord.nix
          nixos-hardware.nixosModules.common-hidpi
          nixos-hardware.nixosModules.common-gpu-nvidia-sync
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
          }
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.barbatos = { imports = [ ./home.nix catppuccin.homeManagerModules.catppuccin ]; };

            home-manager.extraSpecialArgs = {
              repos = inputs;
            };
          }
        ];
      };
    };
  };
}

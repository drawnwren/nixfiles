{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    agenix.url = "github:ryantm/agenix";
    plenary = { flake = false; url = "github:nvim-lua/plenary.nvim"; };
    telescope = { flake = false; url = "github:nvim-telescope/telescope.nvim"; };
  };

  outputs = inputs@{ self, nixpkgs, agenix, home-manager, ... }: {
    nixosConfigurations = {
      enki = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
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
            home-manager.users.barbatos = import ./home.nix;

            extraSpecialArgs = {
              repos = inputs;
            };
          }
        ];
      };
    };
  };
}

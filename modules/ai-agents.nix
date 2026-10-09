# Coding agents shared across hosts. Imported as a system module (NixOS and
# nix-darwin both pass `inputs` through specialArgs).
{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    inputs.claude-code.packages.${system}.default
    inputs.llm-agents.packages.${system}.omp # oh-my-pi
  ];
}

{
  pkgs,
  inputs,
  ...
}: {
  imports = [../darwin-common.nix];

  environment.systemPackages =
    (import ./packages.nix {inherit pkgs;}).core
    ++ [
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
    ];

  users.users.wintermute = {
    home = "/Users/wintermute";
    name = "wintermute";
    shell = pkgs.zsh;
  };

  homebrew = {
    brews = [
      "boost"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
      "brave-browser"
      "codex-app"
      "docker-desktop"
      "slack"
      "discord"
      "spotify"
      "zoom"
      "postman"
      "1password"
      "1password-cli"
      "foxglove"
      "zen"
    ];
  };

  system.primaryUser = "wintermute";

  determinateNix = {
    enable = true;
    customSettings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "dynamic-derivations"
        "recursive-nix"
        "wasm-builtin"
        "wasm-derivations"
      ];
      trusted-users = ["root" "wintermute"];
      substituters = [
        "https://cache.nixos.org"
        "https://codex-cli.cachix.org"
        "https://install.determinate.systems"
        "https://cache.iog.io"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
    };
  };

  networking.hostName = "ninurta";
  networking.computerName = "ninurta";
  networking.localHostName = "ninurta";
}

{pkgs, ...}: {
  imports = [../darwin-common.nix];

  environment.systemPackages = with pkgs; [
    gcc-arm-embedded

    awscli2
    ssm-session-manager-plugin

    bash-language-server
    basedpyright
    bear
    git
    git-lfs
    curl
    dust
    wget
    nix-prefetch-github
    opentofu
    python312Packages.conda

    uv
    terragrunt
    tinyxml
    shellcheck
    shfmt
    terraform-ls
    tmux
    vscode
    obsidian
    ngrok

    teams
    brave
  ];

  users.users.drew = {
    home = "/Users/drew";
    name = "drew";
    shell = pkgs.zsh;
  };

  homebrew = {
    taps = ["PX4/px4"];
    brews = [
      "boost"
      "tinyxml"
      "eigen"
      {
        name = "px4-dev";
        args = ["ignore-dependencies"]; # manually manage cmake because homebrew deps are broken
      }
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
      "brave-browser"
      "docker"
    ];
  };

  system.primaryUser = "drew";

  determinateNix = {
    enable = true;
    customSettings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "drew"];
      substituters = [
        "https://cache.nixos.org"
        "https://codex-cli.cachix.org"
        "https://install.determinate.systems"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };
  };
}

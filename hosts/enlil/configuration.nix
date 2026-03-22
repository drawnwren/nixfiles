{pkgs, inputs  ...}:
{
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
    neovim
    nix-prefetch-github
    opentofu
    python312Packages.conda

    uv
    terragrunt
    tinyxml
    shellcheck
    shfmt
    starship
    terraform-ls
    tmux
    vscode
    obsidian
    ngrok

    teams
    brave
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  ]; 

  users.users.drew = {
    home = "/Users/drew";
    name = "drew";
    shell = pkgs.zsh;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
  ];

  nix.enable = false;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    taps = ["PX4/px4"];
    brews = [
      "bat"
      "boost"
      "node"
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

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    image = null;
  };

  # System defaults
  system = {
    primaryUser = "drew";
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "bottom";
        showhidden = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
    };
  };


  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "drew" ];
    substituters = [
      "https://cache.nixos.org"
      "https://codex-cli.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };
  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;
}

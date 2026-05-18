{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages =
    (import ./packages.nix {inherit pkgs;}).core
    ++ [
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  users.users.wintermute = {
    home = "/Users/wintermute";
    name = "wintermute";
    shell = pkgs.zsh;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
  ];

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    brews = [
      "bat"
      "boost"
      "node"
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

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    image = null;
  };

  system = {
    primaryUser = "wintermute";
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

  determinateNix = {
    enable = true;
    customSettings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "wintermute"];
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

  networking.hostName = "ninurta";
  networking.computerName = "ninurta";
  networking.localHostName = "ninurta";

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;
}

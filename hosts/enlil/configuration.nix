{pkgs, inputs, ...}: {
  # Basic system configuration
  networking.hostName = "enlil";
  
  # System packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    uv
    terragrunt
    terraform
    starship
    tmux
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    obsidian
    ngrok
    ghostty
    microsoft-teams
    brave
    obsidian
  ];

  # Enable fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  users.nix.configureBuildUsers = false;
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.brews = [];
  homebrew.casks = [
    "aerospace"
  ];

  # Stylix theme configuration - similar to your NixOS setup
  stylix = {
    enable = true;
    #image = ./path/to/wallpaper.jpg;
    base16Scheme = "${inputs.catppuccin}/base16/catppuccin-mocha.yaml";
  };

  # System defaults
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 3;
        KeyRepeat = 2;
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


  # nix-darwin specific settings
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "barbatos" ];
  };
  
  # Use Touch ID for sudo
  security.pam.enableSudoTouchIdAuth = true;
}
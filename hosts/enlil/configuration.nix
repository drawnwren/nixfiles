{pkgs, inputs, ...}: {
  # Basic system configuration
  networking.hostName = "enlil";
  
  # System packages
  environment.systemPackages = with pkgs; [
    git
    curl
    claude-code
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
    teams
    brave
    obsidian
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

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.brews = [
    "bat"
  ];
  homebrew.casks = [
    "aerospace"
    "ghostty"
    "brave-browser"
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    image = null;
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
    trusted-users = [ "root" "drew" ];
  };
  
  # Use Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
  
  system.stateVersion = 6;
}
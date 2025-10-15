{pkgs, inputs, config, ...}: 
let
  astyle_3_1 = pkgs.stdenv.mkDerivation {
    pname = "astyle";
    version = "3.1";
    
    src = pkgs.fetchurl {
      url = "https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.1/astyle_3.1_linux.tar.gz";
      sha256 = "sha256-y8xM+ZYpRTS7VvAl1vGZ6/3oGqTCccy9XuHBoxknRdc=";
    };
    
    # Explicitly set unpack format
    unpackCmd = ''
      tar xzf $src
    '';
    
    # The source extracts to a directory named 'astyle'
    sourceRoot = "astyle";

    patchPhase = ''
      sed -i '1i#include <limits.h>' src/astyle_main.cpp
    '';
    
    buildPhase = ''
      cd build/gcc
      make
    '';
    
    installPhase = ''
      mkdir -p $out/bin
      cp bin/astyle $out/bin/
      mkdir -p $out/share/doc/astyle
      cp -r ../../doc/* $out/share/doc/astyle/
    '';

    nativeBuildInputs = with pkgs; [
      gcc
      gnumake
    ];
    
    meta = with pkgs.lib; {
      description = "A Free, Fast, and Small Automatic Formatter for C, C++, C# and Java";
      homepage = "https://astyle.sourceforge.net/";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in
{

  #networking.hostName = "enlil";
  
  # System packages
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
    obsidian


    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  ] ++ [inputs.fh.packages.aarch64-darwin.default astyle_3_1 ];

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

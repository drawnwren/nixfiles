{pkgs, localpkgs,  ... }:
{
  core = with pkgs; [
    # nixos stuff
    home-manager

    # cli utils
    lf
    wget
    htop
    zsh
    silver-searcher
    gnumake
    gdb
    git
    jq
    bind.dnsutils
    linuxPackages.perf
    iptables
    man-pages
    man-pages-posix
    tmux
    neovim
    bat
    nixpkgs-fmt

    # os utils
    pavucontrol
    blueberry
    pass
    mako
    libnotify
    
    wdisplays
    flashfocus
    xdg-utils
    gnome.dconf-editor
    pulseaudio
    playerctl
    libappindicator
    glib
    wl-clipboard
    
    alacritty
    neovide
    rofi-wayland
    waybar
    hyprlock
    swww
    spotify
    slack
    telegram-desktop



    # languages
    cargo
    rustc
    rustup
    nodejs

    ruff-lsp

    # cli junk
    awscli2
    kubectl
    kubernetes-helm
    docker
    fluxcd
    killall
    flameshot
    direnv
    
    clang
    gcc
    go
     
  ];
}

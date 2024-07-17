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
    grim
    slurp
    
    wdisplays
    flashfocus
    xdg-utils
    xdg-desktop-portal-gnome
    dconf-editor
    pulseaudio
    playerctl
    libappindicator
    glib
    wl-clipboard
    
    alacritty
    neovide
    element-desktop-wayland
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
    direnv
    
    clang
    gcc
    go
     
  ];
}

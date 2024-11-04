{pkgs, ... }:
{
  core = with pkgs; [
    smartmontools
    # nixos stuff
    home-manager
    asusctl
    stress-ng

    # cli utils
    dbeaver-bin
    lf
    wget
    htop
    btop
    zsh
    silver-searcher
    google-cloud-sdk
    google-cloud-sdk-gce
    gnumake
    gdb
    git
    git-lfs
    jq
    bind.dnsutils
    linuxPackages.perf
    iptables
    man-pages
    man-pages-posix
    skopeo
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
    cudatoolkit
    sysstat
    
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
    nvtopPackages.full
    
    obsidian
    alacritty
    bun
    fd
    ripgrep
    neovide
    element-desktop-wayland
    gtk4
    gsettings-desktop-schemas
    rofi-wayland
    waybar
    hyprlock
    swww
    spotify
    slack
    discord
    telegram-desktop
    cassandra



    # languages
    cargo
    rustc
    rustup
    nodejs
    poetry

    brave
    nil
    alejandra
    ruff-lsp

    # cli junk
    awscli2
    postman
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

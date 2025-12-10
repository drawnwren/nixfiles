{pkgs, ...}: {
  core = with pkgs; [
    ansible

    smartmontools
    # nixos stuff
    home-manager
    asusctl
    stress-ng

    # cli utils
    dbeaver-bin
    devenv
    lf
    lsof
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
    tree
    trippy
    tmux
    unzip
    neovim
    bat
    nixpkgs-fmt
    nixd
    ngrok

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

    wgnord
    wdisplays
    flashfocus
    xwayland
    xdg-utils
    dconf-editor
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
    element-desktop
    gtk4
    gsettings-desktop-schemas
    rofi
    waybar
    ironbar
    hyprlock
    swww
    spotify
    slack
    discord
    telegram-desktop
    cassandra
    zoom-us
    vscode
    python312Packages.west
    tailscale

    # languages
    cargo
    rustc
    rustup
    nodejs
    pnpm
    poetry
    uv

    brave
    nil
    alejandra
    ruff

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

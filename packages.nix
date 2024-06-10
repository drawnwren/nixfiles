{pkgs, localpkgs, ... }:
{
  core = with pkgs; [
    home-manager
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
    swww



    # languages
    cargo
    rustc
    rustup
    nodejs
    
    clang
    gcc
    go
     
  ];
}

{pkgs, ...}: {
  core = with pkgs; [
    # nix
    nixd
    alejandra
    nix-prefetch-github

    # cli utils
    ansible
    smartmontools
    stress-ng
    dbeaver-bin
    devenv
    lf
    lsof
    wget
    curl
    htop
    btop
    dust
    ripgrep
    google-cloud-sdk
    gnumake
    git
    git-lfs
    jq
    bind.dnsutils
    skopeo
    tree
    trippy
    tmux
    unzip
    ngrok
    pass
    killall
    bear
    tinyxml

    # editors / desktop apps
    obsidian
    vscode
    neovide

    # language servers / linters / formatters
    bash-language-server
    basedpyright
    terraform-ls
    shellcheck
    shfmt
    ruff

    # IaC / cloud
    awscli2
    ssm-session-manager-plugin
    opentofu
    terragrunt
    kubectl
    kubernetes-helm
    fluxcd

    # languages
    rustup
    pnpm
    bun
    uv
    go
    gcc-arm-embedded

    # comms
    telegram-desktop

    # net
    tailscale
  ];
}

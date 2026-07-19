{
  config,
  pkgs,
  repos,
  ...
}: let
  codexPkg = repos.codex-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # libcap is Linux-only; only wrap with LD_LIBRARY_PATH there.
  codexWrapped =
    if pkgs.stdenv.isLinux
    then
      pkgs.symlinkJoin {
        name = "codex";
        paths = [codexPkg];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/codex --set LD_LIBRARY_PATH "${pkgs.libcap}/lib"
        '';
      }
    else codexPkg;
in {
  programs.home-manager.enable = true;

  # The options.json doc build embeds store paths without string context,
  # which newer Nix warns about; skip the generated home-manager manpages.
  manual.manpages.enable = false;

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "drawnwren";
        email = "drawnwren@gmail.com";
      };
    };
    ignores = [
      # Claude-related files
      ".claude/"
      "CLAUDE.md"
      "claude.json"
      ".claude-code/"
    ];
  };
  programs.bat.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    chroma # needed by the oh-my-zsh colorize plugin
    fd
    nodejs
    codexWrapped
  ];

  # init.lua sets catppuccin, which would override stylix's injected
  # mini.base16 theme anyway — don't theme neovim from stylix.
  stylix.targets.neovim.enable = false;

  xdg.enable = true;
  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withPython3 = true;
    withRuby = false;

    plugins = with pkgs.vimPlugins;
      [
        avante-nvim
        catppuccin-nvim
        cmp-buffer
        cmp-cmdline
        cmp-nvim-lsp
        cmp-path
        dressing-nvim
        gitsigns-nvim
        haskell-tools-nvim
        iron-nvim
        nvim-cmp
        nvim-treesitter.withAllGrammars
        nvim-lspconfig
        plenary-nvim
        rustaceanvim
        telescope-nvim
        telescope-ui-select-nvim
        telescope-file-browser-nvim
        vim-vsnip
        vim-fugitive
        vim-sleuth
        lualine-nvim
        nui-nvim
        nvim-dap-ui
        nvim-dap-virtual-text
        which-key-nvim
        none-ls-nvim
        vim-expand-region
      ]
      ++ [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "render-markdown-nvim";
          version = "1";
          src = repos.render-markdown-nvim;
        })
      ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      kubernetes = {disabled = true;};
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    syntaxHighlighting.enable = true;
    enableCompletion = false;
    autosuggestion.enable = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
      share = true;
      size = 10000;
    };
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    initContent = ''
      ${(builtins.readFile ./config/zsh/.zshrc)}
      # Configure fzf to show above prompt
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

      # Enable fzf keybindings for zsh
      bindkey '^T' fzf-file-widget
      bindkey '^R' fzf-history-widget
      bindkey '^I' fzf-completion

      # Enable fzf completion
      zstyle ':completion:*' fzf-search-display true
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "colorize"
        "colored-man-pages"
        "dirpersist"
        "fzf"
        "wd"
        "history"
        "rust"
        "pyenv"
      ];
    };
  };

  home.stateVersion = "24.05";
}

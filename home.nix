{
  pkgs,
  repos,
  ...
}: {
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    ignores = [
      # Claude-related files
      ".claude/"
      "CLAUDE.md"
      "claude.json"
      ".claude-code/"
      ".claude/settings.local.json"
    ];
  };
  programs.bat.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [oh-my-zsh chroma fd];

  stylix = {
    targets = {
      neovim.enable = true;
    };
  };

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

    #extraConfig = ''
    #  :luafile ~/.config/nvim/init.lua
    #'';
    plugins = with pkgs.vimPlugins;
      [
        avante-nvim
        base16-nvim
        copilot-vim
        catppuccin-nvim
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-nvim-lsp-document-symbol
        dressing-nvim
        haskell-tools-nvim
        mini-diff
        mini-pick
        nvim-cmp
        nvim-treesitter.withAllGrammars
        nvim-lspconfig
        plenary-nvim
        rustaceanvim
        telescope-nvim
        telescope-undo-nvim
        telescope-ui-select-nvim
        telescope-file-browser-nvim
        lsp-zero-nvim
        vim-fugitive
        vim-sleuth
        lualine-nvim
        nui-nvim
        nvim-dap-ui
        nvim-dap-virtual-text
        which-key-nvim
        none-ls-nvim
        snacks-nvim
        trouble-nvim
        vim-expand-region
      ]
      ++ [
        # (pkgs.vimUtils.buildVimPlugin {
        #   pname = "codecompanion.nvim";
        #   version = "1";
        #   src = repos.codecompanion-nvim;
        #   propagatedBuildInputs = with pkgs.vimPlugins; [plenary-nvim mini-diff mini-pick telescope-nvim];
        #   dependencies = with pkgs.vimPlugins; [plenary-nvim mini-diff mini-pick telescope-nvim];
        #   prePatch = ''
        #     # Create empty minimal.lua to avoid initialization during build
        #     cat > lua/minimal.lua << EOF
        #     return {}
        #     EOF
        #     # Create empty constants.lua
        #     mkdir -p lua/codecompanion
        #     cat > lua/codecompanion/constants.lua << EOF
        #     return {
        #       -- Add any necessary constants here
        #       CODE_LENS_NS = "codecompanion_lens",
        #       VIRTUAL_TEXT_NS = "codecompanion_vt",
        #       DIAGNOSTICS_NS = "codecompanion_diagnostics",
        #     }
        #     EOF
        #
        #     # Create empty static.lua if needed
        #     cat > lua/codecompanion/actions/static.lua << EOF
        #     local M = {}
        #     M.actions = {}
        #     return M
        #     EOF
        #   '';
        # })
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

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  programs.zsh = {
    enable = true;
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
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
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
        "colorize"
        "history"
        "rust"
        "pyenv"
      ];
      #theme = "cypher";
    };
  };

  home.stateVersion = "24.05";
}

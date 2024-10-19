{pkgs, lib, repos, ...}:

let 
  onePassPath = "~/.1password/agent.sock";
in
{
  programs.home-manager.enable = true;
  programs.bat.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.waybar = {
    enable = true;
  };

  home.packages = with pkgs; [ oh-my-zsh chroma fd swww];

  stylix = {
    targets = { 
      rofi.enable = true; 
      mako.enable = true;
      neovim.enable = true;
      gtk.enable = true;
    };
  };

  programs.rofi = {
    enable = true;
    terminal = "foot";
  };
  services.mako = {
    enable = true;
    defaultTimeout = 2500;
    borderRadius = 10;
  };

  systemd.user.services.swww = {
    Unit = {
      Description = "SWWW wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Create a script to set the wallpaper
  home.file.".local/bin/set-wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if pgrep swww-daemon >/dev/null; then
          swww img ${./resources/strikefreedom_small.gif}
        else
          (swww-daemon 1>/dev/null 2>/dev/null &) && swww img ${./resources/strikefreedom_small.gif}
        fi
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''  
      device {
        name=logitech-usb-receiver
        sensitivity=0.5
      }
      '';
    # misc.font_family = "";
    settings = {
      "$mod" = "SUPER";
      monitor = [
        "eDP-1,2880x1800@120,0x0,1"
        "HDMI-A-1,1920x1080@60,2880x0,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = "1";
        layout = "dwindle";
      };

      input = {
        kb_options = "ctrl:nocaps";

      };

      animation = ["global,0"];

      decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
      
          inactive_opacity = 0.7;
          #shadow_offset = "-7 -7";
          rounding = 15;
      
          blur =  {
              enabled = true;
              xray = true;
              size = 4;
              passes = 1;
              new_optimizations = true;
          };
      
          drop_shadow = "yes";
          shadow_range = 30;
          shadow_render_power = 4;
      };


      exec-once = [
      "${pkgs.mako}/bin/mako &"
      "${pkgs.waybar}/bin/waybar &"
      "$HOME/.local/bin/set-wallpaper"
      ];
      bind =
      [
        "$mod, m, exec, rofi -show drun -show-icons"
        "$mod, SPACE, exec, foot"
        "$mod, f, fullscreen,"
        "$mod, w, killactive"
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"
      ]
      ++ (
        builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        )
        10)
      );
    };
  };
  
  programs.hyprlock.enable = true;

  #xdg.configFile."alacritty/alacritty.toml".source = ./config/alacritty/alacritty.toml;
  #xdg.configFile."ironbar/config.corn".source = ./config/ironbar/config.corn;

  programs.foot =  {  
    enable = true;
  };

  programs.alacritty =  {
    enable = true;
    settings = {
      #font.normal = "DroidSansM Nerd Font Mono";
      keyboard.bindings = [
        {
          action = "Copy";
          key = "C";
          mods = "Control|Shift";
        }
        {
          action = "Paste";
          key = "V";
          mods = "Control|Shift";
        }

      ];
    };
  };

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
    plugins = with pkgs.vimPlugins; [
      nvim-cmp
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lsp-document-symbol
      dressing-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      plenary-nvim
      telescope-nvim
      telescope-undo-nvim
      telescope-ui-select-nvim
      telescope-file-browser-nvim
      lsp-zero-nvim
      vim-fugitive
      lualine-nvim
      nui-nvim
      nvim-dap-ui
      nvim-dap-virtual-text
      which-key-nvim
      none-ls-nvim
    ] ++ [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "catpuccin";
        version = "1";
        src = repos.catpuccin;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "supermaven";
        version = "1";
        src = repos.supermaven;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "avante-nvim";
        version = "1";
        src = repos.avante;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "render-markdown-nvim";
        version = "1";
        src = repos.render-markdown-nvim;
      })
    ];
  };

  programs.git = {
    enable = true;
    userName = "drawnwren";
    userEmail = "drawnwren@gmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    	safe = { directory = "/etc/nixos"; };
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "neovide.desktop" ];
    "applications/pdf" = [ "zathura.desktop" ];
    "image/*" = [ "sxiv.desktop" ];
    "video/png" = [ "mpv.desktop" ];
    "video/jpg" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
  };


  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

    initExtra = ''
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


  programs.ssh = {
    enable = true;
    extraConfig = ''
    Host *
        IdentityAgent ${onePassPath}
    '';
  };

  programs.chromium = {
  	enable = true;
  };
   
  home.stateVersion = "24.05";
}

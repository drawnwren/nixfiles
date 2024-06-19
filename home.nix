{config, pkgs, lib, repos, ...}:

let 
  onePassPath = "~/.1password/agent.sock";
in
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [ oh-my-zsh chroma ];


  wayland.windowManager.hyprland = {
    enable = true;
    # misc.font_family = "";
    settings = {
      "$mod" = "SUPER";
      monitor = "eDP-1,2880x1800@120,0x0,1";

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
      "${pkgs.swww}/bin/swww init &"
      "${pkgs.waybar}/bin/waybar &"
      "${pkgs.mako}/bin/mako &"
      ];
      bind =
      [
        "$mod, m, exec, rofi -show drun -show-icons"
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

  programs.waybar = {
    enable = true;
  };


  

  #xdg.configFile."alacritty/alacritty.toml".source = ./config/alacritty/alacritty.toml;

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
      nvim-dap-ui
      nvim-dap-virtual-text
      which-key-nvim
      null-ls-nvim
    ];
  };

  programs.git = {
    enable = true;
    userName = "drawnwren";
    userEmail = "drawnwren@gmail.com";
    extraConfig = {
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


  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    initExtra = (builtins.readFile ./config/zsh/.zshrc);

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "colorize"
        "colored-man-pages"
        "dirpersist" 
        "wd"
        "colorize"
        "history"
        "rust"
        "pyenv"
      ];
      theme = "cypher";
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

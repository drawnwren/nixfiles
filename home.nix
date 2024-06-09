{config, pkgs, lib, ...}:

let 
  onePassPath = "~/.1password/agent.sock";
in
{
  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      input = {
        kb_options = "ctrl:nocaps";
      };

      animation = ["global,0"];
      exec-once = [
      "${pkgs.swww}/bin/swww init &"
      "${pkgs.waybar}/bin/waybar &"
      "${pkgs.mako}/bin/mako &"
      ];
      bind =
      [
        "$mod, m, exec, rofi -show drun -show-icons"
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


  
  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      :luafile ~/.config/nvim/init.lua
    '';
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
    enableCompletion = true;
    # initExtra = (builtins.readFile ./config/zsh/.zshrc);
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

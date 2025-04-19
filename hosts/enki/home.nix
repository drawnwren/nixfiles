{pkgs, ...}: {
  home.packages = with pkgs; [wgnord];

  programs.foot = {
    enable = true;
  };
  systemd.user.services.wgnord = {
    Unit = {
      Description = "WireGuard NordVPN connection manager";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };

    Service = {
      ExecStart = "${pkgs.wgnord}/bin/wgnord connect";
      Restart = "always";
      RestartSec = "30";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
  
  programs.waybar = {
    enable = true;
  };


  programs.alacritty = {
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
        sensitivity=0.6
      }
    '';
    settings = {
      "$mod" = "SUPER";
      monitor = [
        "eDP-2,2880x1800@120,0x0,1"
        ",highres,2880x0,0.625000"
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

        blur = {
          enabled = true;
          xray = true;
          size = 4;
          passes = 1;
          new_optimizations = true;
        };

        #drop_shadow = "yes";
        shadow = {
          range = 30;
          render_power = 4;
          enabled = true;
        };
      };

      exec-once = [
        "${pkgs.mako}/bin/mako &"
        "${pkgs.waybar}/bin/waybar &"
      ];
      bind =
        [
          "$mod, m, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons"
          "$mod, SPACE, exec, ${repos.ghostty.packages.${pkgs.system}.default}/bin/ghostty"
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

  services.mako = {
    enable = true;
    defaultTimeout = 2500;
    borderRadius = 10;
  };
  
   programs.rofi = {
    enable = true;
    terminal = "ghostty";
  };
  services.mako = {
    enable = true;
    defaultTimeout = 2500;
    borderRadius = 10;
  }
}
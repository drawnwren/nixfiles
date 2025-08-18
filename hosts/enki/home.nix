{
  pkgs,
  repos,
  ...
}: let
  onePassPath = "~/.1password/agent.sock";
in {
  home.packages = with pkgs; [
    wgnord
    numix-cursor-theme
    brightnessctl
    ddcutil
  ];

  programs.git = {
    userName = "drawnwren";
    userEmail = "drawnwren@gmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      safe = {directory = "/etc/nixos";};
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${pkgs.lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
    '';
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = ["neovide.desktop"];
    "applications/pdf" = ["zathura.desktop"];
    "image/*" = ["sxiv.desktop"];
    "video/png" = ["mpv.desktop"];
    "video/jpg" = ["mpv.desktop"];
    "video/*" = ["mpv.desktop"];
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

  programs.ghostty = {
    enable = true;
    settings = {
      # background-blur-radius deprecated, use background-opacity instead
      background-opacity = 0.9;
      minimum-contrast = 1.1;
      font-family = "DroidSansM Nerd Font Mono";
      window-decoration = false;
    };
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

  # Vulkan renderer bypasses EGL issues
  home.sessionVariables = {
    WLR_RENDERER = "vulkan";
  };

  # Create a script to set the wallpaper
  home.file.".local/bin/set-wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if pgrep swww-daemon >/dev/null; then
          swww img ${../../resources/strikefreedom_small.gif}
        else
          (swww-daemon 1>/dev/null 2>/dev/null &) && swww img ${../../resources/strikefreedom_small.gif}
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

      env = [
        "XCURSOR_THEME,Numix-Cursor"
        "XCURSOR_SIZE,24"
      ];

      monitor = [
        "eDP-1,2880x1800@120,0x0,1"
        "eDP-2,2880x1800@120,0x0,1"
        "HDMI-A-1,3840x2160@144,2880x0,1"
        ",preferred,auto,1"
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
        "hyprctl setcursor Numix-Cursor 24"
        "${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl2 set 100%"
      ];

      bind =
        [
          "$mod, m, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons"
          "$mod, SPACE, exec, ${pkgs.ghostty}/bin/ghostty"
          "$mod, f, fullscreen,"
          "$mod, w, killactive"
          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl2 set +10%"
          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl2 set 10%-"
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
    settings = {
      default-timeout = 2500;
      spacing = 5;
      padding = 10;
      border-radius = 10;
    };
  };

  programs.rofi = {
    enable = true;
    terminal = "ghostty";
  };

  # Enable Stylix integration for ghostty on Linux
  stylix = {
    targets = {
      ghostty.enable = true;
    };
  };

  # Cursor configuration
  home.pointerCursor = {
    name = "Numix-Cursor";
    package = pkgs.numix-cursor-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 24;
    };
  };
}

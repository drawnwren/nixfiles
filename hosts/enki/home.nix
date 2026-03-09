{
  pkgs,
  ...
}: let
  onePassPath = "~/.1password/agent.sock";
  btHeadsetMac = "80:C3:BA:4E:8D:CE";
  btIdleDisconnectInterval = "5m";
  cursorTheme = "Numix-Cursor";
  cursorSize = 24;
  wallpaper = ../../resources/strikefreedom_small.gif;
  disconnectHeadsetIfIdle = pkgs.writeShellScript "disconnect-headset-if-idle" ''
    set -eu

    session="$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk -v u="$USER" '$3 == u { print $1; exit }')"
    [ -n "''${session:-}" ] || exit 0

    idle="$(${pkgs.systemd}/bin/loginctl show-session "$session" -p IdleHint --value 2>/dev/null || echo no)"
    [ "$idle" = "yes" ] || exit 0

    ${pkgs.bluez}/bin/bluetoothctl disconnect "${btHeadsetMac}" >/dev/null 2>&1 || true
  '';
in {
  home.packages = with pkgs; [
    wgnord
    numix-cursor-theme
    brightnessctl
    ddcutil
  ];

  programs.git = {
    settings = {
      user = {
        name = "drawnwren";
        email = "drawnwren@gmail.com";
      };
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
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityAgent = onePassPath;
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = ["neovide.desktop"];
    "application/pdf" = ["zathura.desktop"];
    "image/*" = ["sxiv.desktop"];
    "image/png" = ["mpv.desktop"];
    "image/jpeg" = ["mpv.desktop"];
    "video/*" = ["mpv.desktop"];
  };

  systemd.user.services.bt-headset-idle-disconnect = {
    Unit = {
      Description = "Disconnect Bluetooth headset when session is idle";
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${disconnectHeadsetIfIdle}";
    };
  };

  systemd.user.timers.bt-headset-idle-disconnect = {
    Unit = {
      Description = "Periodic Bluetooth headset idle disconnect check";
    };
    Timer = {
      OnBootSec = btIdleDisconnectInterval;
      OnUnitActiveSec = btIdleDisconnectInterval;
      AccuracySec = "30s";
      Unit = "bt-headset-idle-disconnect.service";
    };
    Install = {
      WantedBy = ["timers.target"];
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
          swww img ${wallpaper}
        else
          (swww-daemon 1>/dev/null 2>/dev/null &) && swww img ${wallpaper}
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
        "XCURSOR_THEME,${cursorTheme}"
        "XCURSOR_SIZE,${toString cursorSize}"
      ];

      monitor = [
        "eDP-1,2880x1800@120,0x0,1"
        "HDMI-A-1,3840x2160@120,2880x0,1,bitdepth,12,vrr,1"
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
        "hyprctl setcursor ${cursorTheme} ${toString cursorSize}"
        "${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl2 set 100%"
      ];

      bind =
        [
          "$mod, m, exec, ${pkgs.rofi}/bin/rofi -show drun -show-icons"
          "$mod, SPACE, exec, ${pkgs.ghostty}/bin/ghostty"
          "$mod, TAB, workspace, previous"
          "$mod SHIFT, E, exit"
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
                  toString (x + 1 - (c * 10));
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
    name = cursorTheme;
    package = pkgs.numix-cursor-theme;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = cursorTheme;
      package = pkgs.numix-cursor-theme;
      size = cursorSize;
    };
  };
}

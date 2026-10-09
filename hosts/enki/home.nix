{
  config,
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
  imports = [../../modules/wren.nix];

  home.packages = with pkgs; [
    wgnord
    numix-cursor-theme
    brightnessctl
    ddcutil
  ];

  programs.zsh.initContent = pkgs.lib.mkAfter ''
    nix() {
      if [[ "$1" == develop ]]; then
        local arg
        for arg in "$@"; do
          if [[ "$arg" == -c || "$arg" == --command ]]; then
            command nix "$@"
            return
          fi
        done

        command nix "$@" --command ${pkgs.lib.getExe pkgs.zsh}
      else
        command nix "$@"
      fi
    }
  '';

  programs.git = {
    settings = {
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
      if pgrep awww-daemon >/dev/null; then
          awww img ${wallpaper}
        else
          (awww-daemon 1>/dev/null 2>/dev/null &) && awww img ${wallpaper}
        fi
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # uwsm (programs.hyprland.withUWSM) manages the session. HM's integration adds an
    # exec-once that restarts hyprland-session.target, which now has
    # PropagatesStopTo=graphical-session.target and kills the uwsm session on login.
    systemd.enable = false;
    configType = "lua";
    settings = {
      env = [
        {_args = ["XCURSOR_THEME" cursorTheme];}
        {_args = ["XCURSOR_SIZE" (toString cursorSize)];}
      ];

      monitor = [
        {
          output = "eDP-1";
          mode = "2880x1800@120";
          position = "0x0";
          scale = 1;
        }
        {
          output = "HDMI-A-1";
          mode = "3840x2160@120";
          position = "2880x0";
          scale = 1;
          bitdepth = 12;
          vrr = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      device = {
        name = "logitech-usb-receiver";
        sensitivity = 0.6;
      };

      animation = {
        leaf = "global";
        enabled = false;
      };

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 1;
          layout = "dwindle";
        };

        input = {
          kb_options = "ctrl:nocaps";
        };

        decoration = {
          # See https://wiki.hypr.land/Configuring/Basics/Variables/ for more
          inactive_opacity = 0.7;
          rounding = 15;

          blur = {
            enabled = true;
            xray = true;
            size = 4;
            passes = 1;
            new_optimizations = true;
          };

          shadow = {
            range = 30;
            render_power = 4;
            enabled = true;
          };
        };
      };
    };

    # Binds and startup hooks are Lua function calls, which settings can't express as data.
    extraConfig = ''
      local mod = "SUPER"
      local brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl -d 'amdgpu_bl*'"

      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.mako}/bin/mako")
        hl.exec_cmd("${pkgs.waybar}/bin/waybar")
        hl.exec_cmd("hyprctl setcursor ${cursorTheme} ${toString cursorSize}")
        hl.exec_cmd(brightnessctl .. " set 100%")
      end)

      hl.bind(mod .. " + m", hl.dsp.exec_cmd("${pkgs.rofi}/bin/rofi -show drun -show-icons"))
      hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("${pkgs.ghostty}/bin/ghostty"))
      hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))
      hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
      hl.bind(mod .. " + f", hl.dsp.window.fullscreen())
      hl.bind(mod .. " + w", hl.dsp.window.close())
      hl.bind(mod .. " + h", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + j", hl.dsp.focus({ direction = "down" }))
      hl.bind(mod .. " + k", hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + l", hl.dsp.focus({ direction = "right" }))
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightnessctl .. " set +10%"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightnessctl .. " set 10%-"), { locked = true, repeating = true })

      for i = 1, 10 do
        local key = i % 10 -- workspace 10 is on key 0
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end
    '';
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
    enable = true;
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

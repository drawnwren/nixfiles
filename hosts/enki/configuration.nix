{
  pkgs,
  inputs,
  ...
}: let
  packageset = import ./packages.nix {inherit pkgs;};
in {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    image = ../../resources/strikefreedomfirst.png;
    opacity = {
      terminal = 0.8;
      popups = 0.9;
    };
    fonts = {
      monospace = {
        name = "DroidSansM Nerd Font Mono";
        package = pkgs.nerd-fonts.droid-sans-mono;
      };
      sizes = {
        terminal = 17;
        applications = 20;
        desktop = 20;
      };
    };
  };

  age.identityPaths = ["/home/barbatos/.ssh/agenix_enki"];
  age.secrets.nordToken = {
    file =
      builtins.path {
        name = "nordToken";
        path = ../../secrets;
        filter = path: type: baseNameOf path == "nordToken.age";
      }
      + "/nordToken.age";
    mode = "0400";
  };
  services.wgnord = {
    enable = true;
    country = "canada";
  };

  services.tailscale.enable = true;

  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # Enhanced logging for power events
      TLP_DEBUG = "1";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      TLP_PERSISTENT_DEFAULT = "1";
      # Keep global USB autosuspend but avoid suspending the Bluetooth controller.
      USB_EXCLUDE_BTUSB = "1";
    };
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "dynamic-derivations"];
    trusted-users = ["root" "barbatos"];
    substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://codex-cli.cachix.org"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [pkgs.pciutils];
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./hdmi-gpu-switch.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    #kernelPackages = pkgs.linuxPackages_latest;
  };

  programs.zsh.enable = true;

  fonts = {
    fontconfig = {
      enable = true;
      subpixel.lcdfilter = "default";
      subpixel.rgba = "rgb";
      antialias = true;
      hinting = {
        enable = true;
        autohint = true;
        style = "full";
      };
    };
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.blueman.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  services.displayManager.sddm = {
    enable = true;

    wayland = {
      enable = true;
    };

    enableHidpi = true;
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "ctrl:nocaps";
    };
    #displayManager.gdm.enable = true;
    #desktopManager.gnome.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.barbatos = {
    isNormalUser = true;
    home = "/home/barbatos";
    extraGroups = ["wheel" "networkmanager" "docker" "audio" "video" "render" "input" "rfkill" "i2c"];
    shell = pkgs.zsh;
  };

  services.resolved.enable = true;
  services.chrony.enable = true;
  services.automatic-timezoned.enable = true;
  networking = {
    nameservers = ["1.1.1.1" "9.9.9.9"];
    hostName = "enki";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      # AX210 shares radio resources between Wi-Fi and Bluetooth.
      # Disabling Wi-Fi powersave reduces long-session BT audio degradation.
      wifi.powersave = false;
    };
  };
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "America/SanFrancisco";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable CUPS to print documents.
  services = {
    printing.enable = true;
    envfs.enable = true;
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Keep a fixed 48k clock for Bluetooth while avoiding large playback delay.
    extraConfig.pipewire."92-bluetooth-playback-balance" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.allowed-rates = [48000];
        default.clock.quantum = 1024;
        default.clock.min-quantum = 256;
        default.clock.max-quantum = 2048;
      };
    };
    extraConfig.pipewire-pulse."92-browser-playback-balance" = {
      "pulse.properties" = {
        # Reduce AV sync delay while keeping enough headroom to avoid underruns.
        "pulse.min.req" = "256/48000";
        "pulse.default.req" = "512/48000";
        "pulse.default.frag" = "1024/48000";
        "pulse.default.tlength" = "4096/48000";
      };
    };

    # Better Bluetooth audio codecs
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        # Keep Bluetooth audio on A2DP profiles only (no HFP/HSP telephony switching).
        "bluez5.roles" = ["a2dp_sink" "a2dp_source"];
        # Prefer link stability over max SBC bitrate to reduce crackling.
        "bluez5.enable-sbc-xq" = false;
        "bluez5.enable-msbc" = true;
        # Keep browser/call apps from forcing HFP profile changes.
        "bluez5.autoswitch-profile" = false;
        # Hardware-volume sync can cause pops/crackle on some headsets.
        "bluez5.enable-hw-volume" = false;
      };
    };
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["barbatos"];
  };
  programs.dconf.enable = true;
  programs.light.enable = true;
  programs.nix-ld.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  hardware.i2c.enable = true;

  environment.systemPackages =
    packageset.core
    ++ [
      (pkgs.writeTextFile {
        name = "sddm-theme-config";
        destination = "/share/sddm/themes/breeze/theme.conf.user";
        text = ''
          [General]
          background=${../../resources/strikefreedomfirst.png}
          type=image
        '';
      })
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    LD_LIBRARY_PATH = "${pkgs.openssl.out}/lib";
  };

  environment.pathsToLink = ["/share/zsh"];
  system.stateVersion = "24.05";
}

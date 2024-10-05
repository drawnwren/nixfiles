# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ localpkgs, pkgs, ... }:
let
  packageset = pkgs.callPackage ./packages.nix { inherit localpkgs; };
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night-eighties.yaml";
    image = ./resources/strikefreedomfirst.png;
    opacity = {
      terminal = 0.8;
      popups = 0.9;
    };
    fonts =  {
      monospace = {
        name = "DroidSansM Nerd Font Mono";
        package =  (pkgs.nerdfonts.override { fonts = ["DroidSansMono"]; });
      };
      sizes = {
        terminal = 17;
        applications = 20;
        desktop = 20;
      };
    };
  };
    
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.supergfxd.enable = true;
  services.power-profiles-daemon.enable = true;
  systemd.services.supergfxd.path = [ pkgs.pciutils ];
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  nixpkgs.config.allowUnfree = true;
  imports =
    [ 
      ./hardware-configuration.nix
      ./nvidia.nix
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
    fontconfig.enable = true;
    packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };


  services.blueman.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; 
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
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" "video" "rfkill" ];
    shell = pkgs.zsh;
  };


 services.resolved.enable = true;
 services.chrony.enable = true;
 services.automatic-timezoned.enable = true;
  networking = {
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    hostName = "enki";
    networkmanager = {
      enable = true; 
      dns = "systemd-resolved";
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
     jack.enable = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "barbatos" ];
  };
  programs.dconf.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = packageset.core;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    #NIXOS_OZONE_WL = "1";
  };
  environment.pathsToLink = [ "/share/zsh" ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}


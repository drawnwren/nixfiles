{ lib, pkgs, config, inputs, ... }:

with lib;

let
  cfg = config.services.wgnord;
  ip = getExe' pkgs.iproute2 "ip";
  wgnord = pkgs.wgnord.overrideAttrs (old: {
    src = old.src.overrideAttrs {
      patches = (old.patches or []) ++ [
        ../patches/statelessWgnord.patch
      ];
    };
  });
  generateConfig = pkgs.writeShellScript "wgnord-generate-config" ''
    umask 0077
    mkdir -p /etc/wireguard
    # patch wgnord to only generate the config file
    ${getExe wgnord} connect ${cfg.country} "$(<${config.age.secrets.nordToken.path})" "${template}" "/etc/wireguard/wgnord.conf"
  '';
  template = pkgs.writeText "wgnord-template" ''
    [Interface]
    PrivateKey = PRIVKEY
    Address = 10.5.0.2/32
    MTU = 1350
    DNS = 103.86.96.100,103.86.99.100
    PreUp = ${concatMapStringsSep ";" (route: "${ip} route add ${route} via ${cfg.defaultGateway} dev ${cfg.wiredInterface}") cfg.excludeSubnets}
    PostDown = ${concatMapStringsSep ";" (route: "${ip} route del ${route} via ${cfg.defaultGateway} dev ${cfg.wiredInterface}") cfg.excludeSubnets}
    [Peer]
    PublicKey = SERVER_PUBKEY
    AllowedIPs = 0.0.0.0/0
    Endpoint = SERVER_IP:51820
    PersistentKeepalive = 25
  '';
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];
  
  options.services.wgnord = {
    enable = mkEnableOption "wgnord VPN service";
    
    confinement.enable = mkEnableOption "wgnord VPN confinement";
    
    country = mkOption {
      type = types.str;
      description = "Country code for VPN connection";
    };

    excludeSubnets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of subnets to exclude from VPN routing";
    };

    wiredInterface = mkOption {
      type = types.str;
      description = "Name of the wired network interface";
    };

    defaultGateway = mkOption {
      type = types.str;
      description = "Default gateway IP address";
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable || cfg.confinement.enable) {
      assertions = [
        {
          assertion = config.age.secrets.nordToken != null;
          message = "The Nord token secret is required for wgnord VPN";
        }
      ];
    })
    (mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.excludeSubnets == [] || cfg.defaultGateway != null;
          message = "Default gateway must be set to use wgnord subnet exclusion";
        }
        {
          assertion = config.services.resolved.enable;
          message = "Wg-quick Nord VPN requires systemd resolved to be enabled";
        }
      ];

      networking.wg-quick.interfaces.wgnord = {
        autostart = false;
        configFile = "/etc/wireguard/wgnord.conf";
      };

      systemd.services.wg-quick-wgnord.preStart = generateConfig.outPath;

      programs.zsh.shellAliases = {
        wgnord-up = "sudo systemctl start wg-quick-wgnord";
        wgnord-down = "sudo systemctl stop wg-quick-wgnord";
      };
    })
    (mkIf cfg.confinement.enable {
      vpnNamespaces.wgnord = {
        enable = true;
        wireguardConfigFile = "/etc/wireguard/wgnord.conf";
        accessibleFrom = [ "127.0.0.1" ];
      };
      systemd.services.wgnord.serviceConfig.ExecStartPre = generateConfig;
    })
  ];
}

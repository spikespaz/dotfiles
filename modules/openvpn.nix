# Forked from
# <https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/services/networking/openvpn.nix>
{ config, lib, pkgs, ... }:
let
  inherit (lib) types;

  cfg = config.services.openvpn.alt;

  makeOpenVPNJob = server: name:
    let
      path = lib.makeBinPath
        (builtins.getAttr "openvpn-${name}" config.systemd.services).path;

      upScript = ''
        #! /bin/sh
        export PATH=${path}

        # For convenience in client scripts, extract the remote domain
        # name and name server.
        for var in ''${!foreign_option_*}; do
          x=(''${!var})
          if [ "''${x[0]}" = dhcp-option ]; then
            if [ "''${x[1]}" = DOMAIN ]; then domain="''${x[2]}"
            elif [ "''${x[1]}" = DNS ]; then nameserver="''${x[2]}"
            fi
          fi
        done

        ${server.up}
        ${lib.optionalString server.updateResolvConf
        "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
      '';

      downScript = ''
        #! /bin/sh
        export PATH=${path}
        ${lib.optionalString server.updateResolvConf
        "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
        ${server.down}
      '';

      configFile = pkgs.writeText "openvpn-config-${name}" ''
        errors-to-stderr
        ${lib.optionalString
        (server.up != "" || server.down != "" || server.updateResolvConf)
        "script-security 2"}
        ${server.config}
        ${lib.optionalString (server.up != "" || server.updateResolvConf)
        "up ${pkgs.writeScript "openvpn-${name}-up" upScript}"}
        ${lib.optionalString (server.down != "" || server.updateResolvConf)
        "down ${pkgs.writeScript "openvpn-${name}-down" downScript}"}
        ${if server.authUserPass == null then
          ""
        else if builtins.isAttrs
        server.authUserPass then # it must be a string or path
          "auth-user-pass ${
            pkgs.writeText "openvpn-credentials-${name}" ''
              ${server.authUserPass.username}
              ${server.authUserPass.password}
            ''
          }"
        else
          "auth-user-pass ${server.authUserPass}"}
      '';
    in {
      description = "OpenVPN instance ‘${name}’";

      wantedBy = lib.optional server.autoStart "multi-user.target";
      after = [ "network.target" ];

      path = [ pkgs.iptables pkgs.iproute2 pkgs.nettools ];

      serviceConfig.ExecStart =
        "@${cfg.package}/sbin/openvpn openvpn --suppress-timestamps --config ${configFile}";
      serviceConfig.Restart = "always";
      serviceConfig.Type = "notify";
    };
in {
  ###### interface

  options = {
    services.openvpn.alt.package = lib.mkPackageOption pkgs "openvpn" { };
    services.openvpn.alt.servers = lib.mkOption {
      default = { };

      example = lib.literalExpression ''
        {
          server = {
            config = '''
              # Simplest server configuration: https://community.openvpn.net/openvpn/wiki/StaticKeyMiniHowto
              # server :
              dev tun
              ifconfig 10.8.0.1 10.8.0.2
              secret /root/static.key
            ''';
            up = "ip route add ...";
            down = "ip route del ...";
          };

          client = {
            config = '''
              client
              remote vpn.example.org
              dev tun
              proto tcp-client
              port 8080
              ca /root/.vpn/ca.crt
              cert /root/.vpn/alice.crt
              key /root/.vpn/alice.key
            ''';
            up = "echo nameserver $nameserver | ''${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
            down = "''${pkgs.openresolv}/sbin/resolvconf -d $dev";
          };
        }
      '';

      description = ''
        Each attribute of this option defines a systemd service that
        runs an OpenVPN instance.  These can be OpenVPN servers or
        clients.  The name of each systemd service is
        `openvpn-«name».service`,
        where «name» is the corresponding
        attribute name.
      '';

      type = types.attrsOf (types.submodule {
        options = {
          config = lib.mkOption {
            type = types.lines;
            description = ''
              Configuration of this OpenVPN instance.  See
              {manpage}`openvpn(8)`
              for details.

              To import an external config file, use the following definition:
              `config = "config /path/to/config.ovpn"`
            '';
          };

          up = lib.mkOption {
            default = "";
            type = types.lines;
            description = ''
              Shell commands executed when the instance is starting.
            '';
          };

          down = lib.mkOption {
            default = "";
            type = types.lines;
            description = ''
              Shell commands executed when the instance is shutting down.
            '';
          };

          autoStart = lib.mkOption {
            default = true;
            type = types.bool;
            description = lib.mdDoc
              "Whether this OpenVPN instance should be started automatically.";
          };

          updateResolvConf = lib.mkOption {
            default = false;
            type = types.bool;
            description = ''
              Use the script from the update-resolv-conf package to automatically
              update resolv.conf with the DNS information provided by openvpn. The
              script will be run after the "up" commands and before the "down" commands.
            '';
          };

          authUserPass = lib.mkOption {
            default = null;
            description = ''
              This option can be used to store the username / password credentials
              with the "auth-user-pass" authentication method.

              You can either provide an attribute set of `username` and `password`,
              or the path to a file containing the credentials on two lines.

              WARNING: If you use an attribute set, this option will put the credentials WORLD-READABLE into the Nix store!
            '';
            type = types.oneOf [
              types.path
              (types.submodule {
                options = {
                  username = lib.mkOption {
                    description = lib.mdDoc
                      "The username to store inside the credentials file.";
                    type = types.str;
                  };

                  password = lib.mkOption {
                    description = lib.mdDoc
                      "The password to store inside the credentials file.";
                    type = types.str;
                  };
                };
              })
            ];
          };
        };
      });
    };
  };

  ###### implementation

  config = lib.mkIf (cfg.servers != { }) {
    systemd.services = lib.listToAttrs (lib.mapAttrsFlatten (name: value:
      lib.nameValuePair "openvpn-${name}" (makeOpenVPNJob value name))
      cfg.servers);

    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "tun" ];
  };
}

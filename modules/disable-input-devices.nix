{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.programs.disable-input-devices;
in {
  options = {
    programs.disable-input-devices = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Installs a script to `PATH` that when executed either enables or
        disables  all of the devices specified by {option}`disableDevices`.

        The script takes a single positional argument
        that is either `enable` or `disable`.
      '');
      script = lib.mkOption {
        type = types.package;
        readOnly = true;
      };
      disableDevices = lib.mkOption {
        type = types.attrsOf (types.submodule ({ name, ... }: {
          options = {
            name = lib.mkOption {
              type = types.strMatching "^([a-z0-9_-]+)(/[a-z0-9_-]+)*$";
              default = name;
              description = lib.mdDoc "";
              example = lib.literalExpression "";
            };
            product = lib.mkOption {
              type = types.strMatching "^([a-z0-9]{4})$";
              description = lib.mdDoc "";
              example = lib.literalExpression "";
            };
            vendor = lib.mkOption {
              type = types.strMatching "^([a-z0-9]{4})$";
              description = lib.mdDoc "";
              example = lib.literalExpression "";
            };
          };
        }));
        default = { };
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
      allowedUsers = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
      allowedGroups = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
    };
  };

  config = lib.mkIf cfg.enable
    (let lockFile = "/var/lock/disable-input-devices.lock";
    in {
      programs.disable-input-devices.script = pkgs.writeShellApplication {
        name = "disable-input-devices";
        runtimeInputs = with pkgs; [ bash coreutils evtest ];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then
            echo 'Script must be run as root!'
            exit 1
          fi
          mode="$1"
          if [[ "$mode" = 'disable' ]]; then
            pids=()
            ${
              lib.concatMapStrings (name: ''
                evtest --grab '/dev/${name}' 1>/dev/null 2>&1 &
                pids+=($!)
                echo "disabled: /dev/${name} ''${pids[-1]}"
                echo "''${pids[-1]}" >> '${lockFile}'
              '') (builtins.attrNames cfg.disableDevices)
            }
            echo "''${pids[@]}"
          elif [[ "$mode" = 'release' ]]; then
            mapfile -t pids < '${lockFile}'
            kill "''${pids[@]}" || true
            rm -f '${lockFile}'
          else
            echo 'Script must be run with an argument: either "disable" or "release".'
            exit 1
          fi
        '';
      };

      environment.systemPackages = [ cfg.script ];

      services.udev.extraRules = lib.concatMapStrings
        ({ name, product, vendor, }: ''
          SUBSYSTEMS=="input", ATTRS{id/product}=="${product}", ATTRS{id/vendor}=="${vendor}", SYMLINK+="${name}"
        '') (builtins.attrValues cfg.disableDevices);

      security.sudo.extraRules = [{
        users = cfg.allowedUsers;
        groups = cfg.allowedGroups;
        commands = [{
          command = lib.getExe cfg.script;
          options = [ "NOPASSWD" ];
        }];
      }];
    });
}

{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  inherit (import ./common.nix null) baseName version src;
  optionName = baseName;
  cfg = config.programs.${optionName};
in {
  options = {
    programs.${optionName} = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Installs a script to `PATH` that when executed either enables or
        disables  all of the devices specified by {option}`disableDevices`.

        The script takes a single positional argument
        that is either `enable` or `disable`.
      '');
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
  config = lib.mkIf cfg.enable (let
    package = pkgs.stdenv.mkDerivation {
      pname = baseName;
      inherit version src;

      strictDeps = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];

      installPhase = let
        scriptPath = lib.makeBinPath (with pkgs; [ bash coreutils evtest ]);
        DISABLE_DEVICES = lib.pipe cfg.disableDevices [
          builtins.attrNames
          (map (name: "/dev/${name}"))
          (lib.concatStringsSep ":")
        ];
      in ''
        install -Dm755 disable-devices.sh $out/bin/${baseName}

        wrapProgram $out/bin/${baseName} \
          --set PATH '${scriptPath}' \
          --set DISABLE_DEVICES '${DISABLE_DEVICES}'
      '';
    };
  in {
    environment.systemPackages = [ package ];

    services.udev.extraRules = lib.pipe cfg.disableDevices [
      builtins.attrValues
      (map ({ name, product, vendor, }: ''
        SUBSYSTEMS=="input", ATTRS{id/product}=="${product}", ATTRS{id/vendor}=="${vendor}", SYMLINK+="${name}"
      ''))
      lib.concatStrings
    ];

    security.sudo.extraRules = [{
      users = cfg.allowedUsers;
      groups = cfg.allowedGroups;
      commands = [{
        command = lib.getExe package;
        options = [ "NOPASSWD" ];
      }];
    }];
  });
}

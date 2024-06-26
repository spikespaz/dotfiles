{ lib, pkgs, config, ... }:
let
  inherit (lib) types;

  # cfg for program
  protonPackages = config.programs.steam.protonPackages;
  gloriousEggrolls = config.programs.steam.protonGE.versions;

  intermediateDirectory = "steam-compatibility-tools";

  fetchProtonGE = version: hash:
    let name = "GE-Proton${version}";
    in pkgs.fetchzip {
      inherit name hash;
      url =
        "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${name}/${name}.tar.gz";
    };

in {
  options = {
    programs.steam.protonPackages = lib.mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
    programs.steam.protonGE = {
      versions = lib.mkOption {
        type = types.attrsOf (types.singleLineStr);
        default = { };
      };
    };

    services.steam = {
      enable = lib.mkEnableOption
        "Start the Steam Desktop client minimized and silent on startup";
      program = lib.mkOption {
        type = types.either types.path types.package;
        default = "/run/current-system/sw/bin/steam";
        description = "The binary package or package to use for the service.";
        apply = x: if lib.isDerivation x then lib.getExe x else x;
      };
      extraArgs = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
        description = ''
          A list of extra arguments to pass to the Steam binary when starting it
          silently as a service. Affects windows opened from the system tray.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      xdg.dataFile = lib.mapListToAttrs (package: {
        name = "${intermediateDirectory}/${package.name}";
        value = {
          source = package.outPath;
          # This is an unsophisticated hack. It will leave broken links when
          # Proton packages are removed from the configuration, and it does not
          # respect Home Manager's `--backup` flag. It eagerly removes the
          # existing target, if any. Also, if you remove the target, you must
          # replace it. The removal of the target is not detected or rectified.
          #
          # Many people would tell me to never do this, that it contradicts
          # the purpose of Nix and it is not implemented robustly enough.
          # And, they would be correct, but I don't care.
          onChange = let
            # The following command does not work, it will create write-protected
            # links which cannot be removed without `sudo`.
            # ```
            # $DRY_RUN_CMD cp -rs "$proton_src"'/' -T "$proton_dest"
            # ```
            # So we use this instead.
            lndir = lib.getExe pkgs.xorg.lndir;
          in ''
            (
              steam_tools_dir='${config.xdg.dataHome}/Steam/compatibilitytools.d'
              proton_src='${config.xdg.dataHome}/${intermediateDirectory}/${package.name}'
              proton_dest="$steam_tools_dir/${package.name}"

              if [[ -e "$proton_dest" ]]; then
                echo "Destination '$proton_dest' exists, removing."
                $DRY_RUN_CMD rm -rf "$proton_dest"
              fi

              echo "Linking '$proton_dest' recursively."
              $DRY_RUN_CMD mkdir -p "$proton_dest"
              $DRY_RUN_CMD ${lndir} -silent "$proton_src" "$proton_dest"
            )
          '';
        };
      }) protonPackages;
    }
    # Recursive linking must be used because Steam doesn't work well with links
    # of any kind. While this works, it is probably still somewhat incompatible.
    # It is also slow (on every profile activation), which is why it's disabled.
    # There is a hack that avoids the slowness above.
    # {
    #   xdg.dataFile = lib.mapListToAttrs (package: {
    #     name = "Steam/compatibilitytools.d/${package.name}";
    #     value = {
    #       recursive = true;
    #       source = package.outPath;
    #     };
    #   }) protonPackages;
    # }
    {
      programs.steam.protonPackages =
        lib.mapAttrsToList (ver: hash: fetchProtonGE ver hash) gloriousEggrolls;
    }
    (lib.mkIf config.services.steam.enable {
      systemd.user.services.steam = {
        Unit = {
          Description = "Steam Desktop Client for Linux";
          After = [ "network.target" "graphical-session.target" ];
          StartLimitIntervalSec = 300;
          StartLimitBurst = 5;
        };
        Service = {
          Type = "simple";
          ExecStart = "${config.services.steam.program} ${
              lib.escapeShellArgs
              ([ "-silent" ] ++ config.services.steam.extraArgs)
            }";
          Restart = "unless-stopped";
          RestartSec = "1s";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    })
  ];
}

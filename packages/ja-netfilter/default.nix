args @ {
  lib,
  fetchgit,
  callPackage,
  symlinkJoin,
  programName ? null,
  enabledPlugins ? null,
  configFiles ? null,
}: let
  ja-netfilter = callPackage (import ./packages.nix args).ja-netfilter {};
  callPlugin = name: callPackage (import ./packages.nix args)."plugin-${name}" {};
  pluginPackages = lib.optionals (enabledPlugins != null) (map callPlugin enabledPlugins);
in
  symlinkJoin {
    name =
      if programName == null
      then "ja-netfilter"
      else "ja-netfilter-${programName}";
    paths = [ja-netfilter] ++ pluginPackages;
    postBuild = ''
      mv $out/share/ja-netfilter/plugins $out/share/ja-netfilter/plugins-${programName}

      mkdir -p $out/share/ja-netfilter/config-${programName}

      ${lib.optionalString (configFiles != null) (
        lib.pipe configFiles [
          (lib.mapAttrsToList (name: text: ''
            cat << EOF > $out/share/ja-netfilter/config-${programName}/${name}.conf
            ${text}
            EOF
          ''))
          (lib.concatStringsSep "\n")
        ]
      )}
    '';
  }

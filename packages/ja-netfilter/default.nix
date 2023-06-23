{ lib, writeTextDir, callPackage, symlinkJoin, programName ? null
, enabledPlugins ? null, pluginConfigs ? null, }:
let
  packages = callPackage ./packages.nix { };
  ja-netfilter = callPackage packages.ja-netfilter { };
  callPlugin = name: callPackage packages."plugin-${name}" { };
  pluginPackages =
    lib.optionals (enabledPlugins != null) (map callPlugin enabledPlugins);
  configFiles = lib.optionals (pluginConfigs != null) (lib.mapAttrsToList
    (name: value: writeTextDir "share/ja-netfilter/config/${name}.conf" value)
    pluginConfigs);
in symlinkJoin {
  name = if programName == null then
    "ja-netfilter"
  else
    "ja-netfilter-${programName}";
  paths = [ ja-netfilter ] ++ pluginPackages ++ configFiles;
  postBuild = lib.optionalString (programName != null) ''
    mv $out/share/ja-netfilter/plugins $out/share/ja-netfilter/plugins-${programName}
    mv $out/share/ja-netfilter/config $out/share/ja-netfilter/config-${programName}
  '';
}

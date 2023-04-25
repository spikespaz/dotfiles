args@{ lib, fetchgit, writeTextDir, callPackage, symlinkJoin, programName ? null
, enabledPlugins ? null, pluginConfigs ? null, }:
let
  ja-netfilter = callPackage (import ./packages.nix args).ja-netfilter { };
  callPlugin = name:
    callPackage (import ./packages.nix args)."plugin-${name}" { };
  pluginPackages =
    lib.optionals (enabledPlugins != null) (map callPlugin enabledPlugins);
  configFiles = lib.optionals (pluginConfigs != null) (lib.mapAttrsToList
    (name: value:
      writeTextDir "share/ja-netfilter/config-${programName}/${name}.conf"
      value) pluginConfigs);
in symlinkJoin {
  name = if programName == null then
    "ja-netfilter"
  else
    "ja-netfilter-${programName}";
  paths = [ ja-netfilter ] ++ pluginPackages ++ configFiles;
  postBuild = ''
    mv $out/share/ja-netfilter/plugins $out/share/ja-netfilter/plugins-${programName}
  '';
}

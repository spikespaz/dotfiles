{ lib, callPackages, runCommandLocal, programName ? null, enabledPlugins ? [ ]
, pluginConfigs ? { }, }:
let
  packages = callPackages ./packages.nix { };
  suffixProgram = string:
    if programName == null then string else "${string}-${programName}";
  buildName = suffixProgram "ja-netfilter";
  pluginsDir = suffixProgram "plugins";
  configsDir = suffixProgram "config";
  configFileArgs = lib.mapAttrs' (pluginName: text: {
    name = "${pluginName}_config";
    value = text;
  }) pluginConfigs;
  derivationArgs = configFileArgs // {
    passAsFile = lib.attrNames configFileArgs;
  };
in runCommandLocal buildName derivationArgs ''
  mkdir -p $out/share/ja-netfilter
  mkdir $out/share/ja-netfilter/{${pluginsDir},${configsDir}}

  cp ${packages.ja-netfilter}/ja-netfilter-jar-with-dependencies.jar \
    $out/share/ja-netfilter/ja-netfilter.jar

  ${lib.concatLines (map (pluginName:
    let plugin = packages."ja-netfilter-plugin-${pluginName}";
    in ''
      cp ${plugin}/${pluginName}-v${plugin.version}-jar-with-dependencies.jar \
        $out/share/ja-netfilter/${pluginsDir}/${pluginName}.jar
    '') enabledPlugins)}

  ${lib.concatLines (lib.mapAttrsToList (pluginName: configText: ''
    mv ''$${pluginName}_configPath \
      $out/share/ja-netfilter/${configsDir}/${pluginName}.conf
  '') pluginConfigs)}
''

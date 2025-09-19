{ lib, pkgs, ... }:
let
  ja-netfilter = pkgs.ja-netfilter.override {
    programName = "jetbrains";
    enabledPlugins = [ "dns" "url" "hideme" "power" ];
    pluginConfigs = lib.importJSON ./plugin-configs.json;
  };
  javaAgentJar = "${ja-netfilter}/share/ja-netfilter/ja-netfilter.jar";
  vmopts = ''
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
    -javaagent:${javaAgentJar}=jetbrains
  '';
  forkingWrapper = package: wrapperName:
    let
      exe = lib.getExe package;
      wrapperExe = pkgs.writeShellScriptBin wrapperName ''
        ${exe} "$@" >/dev/null 2>&1 &
      '';
    in pkgs.symlinkJoin {
      name = package.name;
      paths = [ package wrapperExe ];
      postBuild = ''
        ln -s ${exe} $out/bin/${wrapperName}-unwrapped
      '';
    };
  wrapJetBrains = package: name:
    forkingWrapper (package.override { inherit vmopts; }) name;
  versionYearMinor = version:
    let split = lib.splitVersion version;
    in "${lib.elemAt split 0}.${lib.elemAt split 1}";
in {
  clion = let clion' = wrapJetBrains pkgs.jetbrains.clion "clion";
  in { home.packages = [ clion' ]; };

  goland = let goland' = wrapJetBrains pkgs.jetbrains.goland "goland";
  in { home.packages = [ goland' ]; };

  webstorm = let webstorm' = wrapJetBrains pkgs.jetbrains.webstorm "webstorm";
  in { home.packages = [ webstorm' ]; };

  idea = let
    super = pkgs.jetbrains.idea-ultimate;
    idea' = wrapJetBrains super "idea";
    keyPath =
      "JetBrains/IntelliJIdea${versionYearMinor super.version}/idea.key";
  in {
    home.packages = [ idea' ];
    xdg.configFile.${keyPath}.source = ./licenses/idea.key;
  };

  pycharm =
    let pycharm' = wrapJetBrains pkgs.jetbrains.pycharm-professional "pycharm";
    in { home.packages = [ pycharm' ]; };
}

{ lib }:
let
  wrapShellScript = pkgs: script: path:
    let name = builtins.baseNameOf script;
    in pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      phases = [ "installPhase" ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      installPhase = ''
        makeWrapper ${script} $out \
          --set PATH '${lib.makeBinPath path}'
      '';
    };

  writeShellScriptShebang = pkgs: shell: name: text:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${lib.getExe shell}
        ${text}
      '';
    };

  writeNuScript = pkgs: name: text:
    writeShellScriptShebang pkgs pkgs.nushell "${name}.nu" text;
in {
  #
  inherit wrapShellScript writeShellScriptShebang writeNuScript;
}

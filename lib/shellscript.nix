{ lib }:
let
  writeShellScriptShebang = pkgs: package: name: text:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${lib.getExe package}
        ${text}
      '';
    };

  writeNuScript = pkgs: name: text:
    writeShellScriptShebang pkgs pkgs.nushell "${name}.nu" text;
in {
  #
  inherit writeShellScriptShebang writeNuScript;
}

final: prev: rec {
  writeShellScriptShebang = package: name: text:
    final.writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${prev.lib.getExe package}
        ${text}
      '';
    };

  writeNuScript = name: text:
    writeShellScriptShebang final.nushell "${name}.nu" text;
}

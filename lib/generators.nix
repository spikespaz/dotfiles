{ lib }:
let
  # This is a bad solution
  toTOMLFile = pkgs: name: attrs:
    (pkgs.runCommandLocal "nix-to-toml_${name}" { } ''
      mkdir $out
      cat "${pkgs.writeText "nix-to-json-${name}" (builtins.toJSON attrs)}" \
        | ${lib.getExe pkgs.yj} -jt > "$out/${name}.toml"
    '').outPath + "/${name}.toml";

  toTOML = attrs: builtins.readFile (toTOMLFile "unknown" attrs);
in {
  #
  inherit toTOMLFile toTOML;
}

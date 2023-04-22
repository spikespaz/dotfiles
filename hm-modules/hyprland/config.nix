{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.alt;
in {
  options = {
    wayland.windowManager.hyprland.alt = {
      enableConfig = lib.mkEnableOption "Nix-generated Hyprland config";
      config = lib.mkOption {
        type = types.attrs;
        default = {};
        description = lib.mdDoc "Hyprland config attributes";
      };
    };
  };

  config = let
    indent = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));
    indent' = indent "    ";
    configSection = level: attrs: let
      lines = lib.filterAttrs (_: v: !(lib.isAttrs v)) attrs;
      sections = lib.filterAttrs (_: lib.isAttrs) attrs;
    in
      lib.concatStrings (
        # Top level config attributes
        (lib.mapAttrsToList (
            name: value: "\n${indent' level}${name} = ${valueToString value}"
          )
          lines)
        # Then the sections
        ++ (lib.mapAttrsToList (
            name: value: "\n${indent' level}${name} {${configSection (level + 1) value}\n${indent' level}}"
          )
          sections)
      );
    valueToString = value:
      if lib.isBool value
      then lib.boolToString value
      else if lib.isInt value || lib.isFloat value
      then toString value
      else if lib.isString value
      then value
      else if lib.isList value
      then lib.concatMapStringsSep " " valueToString value
      else abort (lib.traceSeqN 2 value "Invalid value, cannot convert '${builtins.typeOf value}' to Hyprland config string value");
  in
    lib.mkIf cfg.enableConfig {
      xdg.configFile."hypr/hyprland.conf".text = lib.traceVal (configSection 0 cfg.config);
    };
}

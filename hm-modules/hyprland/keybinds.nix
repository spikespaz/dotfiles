args@{ config, lib, pkgs, ... }:
let
  cfg = config.wayland.windowManager.hyprland;

  inherit (lib) types;

  inherit (configFormat.lib)
    mkVariableNode mkRepeatNode formatNodeList renderNodeList;

  configFormat = (import ./configFormat.nix args) cfg.configFormatOptions;

  sublist = idx: j: l:
    let adv = j - idx;
    in lib.foldl' (l': i: l' ++ [ builtins.elemAt i l ]) [ ]
    (lib.range idx adv);

  toConfigString = opts: keyBinds:
    lib.pipe keyBinds [
      (keyBindsToNodeList [ ])
      (lib.traceValSeqN 10)
      (formatNodeList opts)
      (renderNodeList opts)
    ];

  keyBindsToNodeList = path: attrs:
    let
      default = lib.pipe attrs [
        (attrs:
          if attrs ? submap then removeAttrs attrs [ "submap" ] else attrs)
        (bindAttrsToNodeList [ ])
      ];
      # submaps = lib.pipe attrs [
      #   (attrs: if attrs ? submap then attrs.submap else { })
      # ];
    in lib.concatLists [ default ];

  bindAttrsToNodeList = path:
    (lib.mapAttrsToList (bindKw: chordAttrs:
      mkRepeatNode path bindKw (chordAttrsToNodeList path bindKw chordAttrs)));

  chordAttrsToNodeList = path: bindKw: attrs:
    lib.concatLists (lib.mapAttrsToList (chord: value:
      if lib.isList value then
        (map (dispatcher: mkVariableNode path bindKw "${chord}, ${dispatcher}")
          value)
      else
        [ (mkVariableNode path bindKw "${chord}, ${value}") ]) attrs);
in {
  options = {
    wayland.windowManager.hyprland.keyBinds = lib.mkOption {
      type = with types; attrsOf anything;
      default = { };
      description = lib.mdDoc ''
        First-level attribute name is the type of bind to use,
        for example: `bindm` for repeated mouse movements,
        or `bindr` to trigger on release. [See the wiki].

        Second-level attribute name is a keychord in the form of `[MOD_KEYS],<xkb_key>`,
        with the comma optionally followed by a space.

        Use the names from that header without the `XKB_KEY_` prefix here.

        Replace `[MOD_KEYS]` with a list of key names in UPPERCASE,
        separated by a space, underscore, or nothing.

        Replace `<xkb_key>` with a single key name in lower snake case,
        or as it should appear in the [`keysyms` header][1].

        For key names use the [`xkbcommon-keysms.h` header][1].

        Second-level attribute value is a dispatcher command,
        either a string or a list. A list will be concatenated by commas.

        [0]: https://wiki.hyprland.org/Configuring/Binds/#basic]
        [1]: https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      '';
      example = lib.literalExpression ''
        {
          bindm."SUPER, ''${MOUSE_LMB}" = "movewindow";
          bindm."SUPER, ''${MOUSE_RMB}" = "resizewindow";

          bindm.", ''${MOUSE_EX2}" = "movewindow";
          bindm.", ''${MOUSE_EX1}" = "resizewindow";

          bind."SUPER_SHIFT, left" = "movewindow, l";
          bind."SUPER_SHIFT, right" = "movewindow, r";
          bind."SUPER_SHIFT, up" = "movewindow, u";
          bind."SUPER_SHIFT, down" = "movewindow, d";

          bind."SUPER, slash" = "submap, resize";
          submap.resize = {
            binde.", right" = "resizeactive, 10 0";
            binde.", left" = "resizeactive, -10 0";
            binde.", up" = "resizeactive, 0 -10";
            binde.", down" = "resizeactive, 0 10";
            binde."SHIFT, right" = "resizeactive, 30 0";
            binde."SHIFT, left" = "resizeactive, -30 0";
            binde."SHIFT, up" = "resizeactive, 0 -30";
            binde."SHIFT, down" = "resizeactive, 0 30";
            bind.", escape" = "submap, reset";
            bind."CTRL, C" = "submap, reset";
          };
        }
      '';
    };
  };

  config = {
    xdg.configFile."hypr/keybinds.conf".text =
      toConfigString cfg.configFormatOptions cfg.keyBinds;

    #    wayland.windowManager.hyprland.config.source =
    #      [ "${config.xdg.configHome}/hypr/keybinds.conf" ];
  };
}

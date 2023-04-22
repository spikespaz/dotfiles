{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.windowRules;
in {
  options = {
    wayland.windowManager.hyprland.windowRules = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          class = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
          };
          title = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
          };
          rules = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
          };
        };
      });

      default = [];

      description = lib.mdDoc ''
        List of sets containing:

         - `rules` = List of rules to apply to matched windows.
         - `class` = List of patterns to test the window class against.
         - `title` = List of patterns to test the window title against.

         See the example for more information.

         As an addendum, something you may want to use is this:

        ```nix
        let
          rule = {
            class ? null,
            title ? null,
          }: rules: {inherit class title rules;};
        in
          with patterns;
            lib.concatLists [
              (rule obsStudio ["size 1200 800" "workspace 10"])

              (map (rule ["float"]) [
                printerConfig
                audioControl
                bluetoothControl
                kvantumConfig
                filePickerPortal
                polkitAgent
                mountDialog
                calculator
                obsStudio
                steam
              ])
            ]
        ]
        ```
      '';

      example = lib.literalExpression ''
        let
          obsStudio = {
            class = ["com.obsproject.Studio"];
            title = ["OBS\s[\d\.]+.*"];
          };
          # match both WebCord and Discord clients
          # by two class names this will end up as
          # ^(WebCord|discord)$
          # in the config file.
          discord.class = ["WebCord" "discord"];
        in [
          # open OBS Studio on a specific workspace with an initial size
          (obsStudio // {rules = ["size 1200 800" "workspace 10"];})
          # make WebCord and Discord slightly transparent
          (discord // {rules = ["opacity 0.93 0.93"];})
        ]
      '';
    };
  };

  config = let
    expandRule = {
      rules,
      class ? null,
      title ? null,
    }: (
      map (rule: {
        inherit rule class title;
      })
      rules
    );
    compileRule = {
      rule,
      class,
      title,
    }: {
      inherit rule;
      class =
        lib.mapNullable
        (x: "class:^(${lib.concatStringsSep "|" x})$")
        class;
      title =
        lib.mapNullable
        (x: "title:^(${lib.concatStringsSep "|" x})$")
        title;
    };
    stringifyRule = {
      rule,
      class,
      title,
    }: "${lib.concatStringsSep ", " (
      [rule]
      ++ (lib.optional (class != null) class)
      ++ (lib.optional (title != null) title)
    )}";
  in {
    wayland.windowManager.hyprland.alt.config.windowrulesv2 = lib.pipe cfg [
      (map expandRule)
      lib.concatLists
      (map compileRule)
      (map stringifyRule)
    ];
  };
}

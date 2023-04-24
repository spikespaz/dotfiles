{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland;
in {
  options = {
    wayland.windowManager.hyprland.windowRules = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          class = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
            description = lib.mdDoc ''
              A list of class names to match against.
            '';
          };
          title = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
            description = lib.mdDoc ''
              A list of window titles to match against.
            '';
          };
          rules = lib.mkOption {
            type = types.nullOr (types.listOf types.singleLineStr);
            default = null;
            description = lib.mdDoc ''
              A list of window rules to apply to a window matching
              both the class names and titles given.
            '';
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
    # Given a second-form window rule (one with a `rules` list)
    # convert it into a list of first-form window rules
    # (one with a single string value for the `rule` attr).
    expandWindowRuleToList = rule2:
      map (rule: {
        inherit (rule2) class title;
        inherit rule;
      })
      rule2.rules;
    # Given a window rule in second- or first-form
    # (with `rule` or `rules` attr respectively),
    # turn the `class` and `title` list into regex patterns
    # matching any string in each list.
    compileWindowRulePatterns = rule:
      rule
      // {
        class =
          lib.mapNullable
          (x: "class:^(${lib.concatStringsSep "|" x})$")
          rule.class;
        title =
          lib.mapNullable
          (x: "title:^(${lib.concatStringsSep "|" x})$")
          rule.title;
      };
    # Convert a rule (first-form) into a valid string value for
    # a Hyprland config variable.
    windowRuleToString = rule:
      lib.concatStringsSep ", " (
        [rule.rule]
        ++ (lib.optional (rule.class != null) rule.class)
        ++ (lib.optional (rule.title != null) rule.title)
      );

    _traceMsgVal = msg: val: "${msg}\n${lib.generators.toPretty {multiline = true;} val}";

    traceM = m: v: builtins.trace (_traceMsgVal m v);
    traceValM = m: v: builtins.trace (_traceMsgVal m v) v;
  in {
    wayland.windowManager.hyprland.config.windowrulev2 = lib.pipe cfg.windowRules [
      # right now we have window rules in second-form,
      # each "rule" has a `rules` attr which is a list of string-rules.
      #
      # the first step is to turn `class` and `title` into regex strings
      # for each second-form rule.
      (map compileWindowRulePatterns)
      # then expand each into a list of rules in first-form,
      # with `rule` instead of `rules`.
      (map expandWindowRuleToList)
      # combine the intermediate lists to a single list of first-form rules.
      lib.concatLists
      # map each to a Hyprland config variable value string.
      (map windowRuleToString)
    ];
  };
}

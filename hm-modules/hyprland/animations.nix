{ config, lib, ... }:
let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.animations;

  defaultBezierCurves = {
    linear = [ 0 0 1 1 ];

    easeInSine = [ 0.12 0 0.39 0 ];
    easeOutSine = [ 0.61 1 0.88 1 ];
    easeInOutSine = [ 0.37 0 0.63 1 ];

    easeInQuad = [ 0.11 0 0.5 0 ];
    easeOutQuad = [ 0.5 1 0.89 1 ];
    easeInOutQuad = [ 0.45 0 0.55 1 ];

    easeInCubic = [ 0.32 0 0.67 0 ];
    easeOutCubic = [ 0.33 1 0.68 1 ];
    easeInOutCubic = [ 0.65 0 0.35 1 ];

    easeInQuart = [ 0.5 0 0.75 0 ];
    easeOutQuart = [ 0.25 1 0.5 1 ];
    easeInOutQuart = [ 0.76 0 0.24 1 ];

    easeInQuint = [ 0.64 0 0.78 0 ];
    easeOutQuint = [ 0.22 1 0.36 1 ];
    easeInOutQuint = [ 0.83 0 0.17 1 ];

    easeInExpo = [ 0.7 0 0.84 0 ];
    easeOutExpo = [ 0.16 1 0.3 1 ];
    easeInOutExpo = [ 0.87 0 0.13 1 ];

    easeInCirc = [ 0.55 0 1 0.45 ];
    easeOutCirc = [ 0 0.55 0.45 1 ];
    easeInOutCirc = [ 0.85 0 0.15 1 ];

    easeInBack = [ 0.36 0 0.66 (-0.56) ];
    easeOutBack = [ 0.34 1.56 0.64 1 ];
    easeInOutBack = [ 0.68 (-0.6) 0.32 1.6 ];
  };
in {
  options = {
    wayland.windowManager.hyprland.animations = {
      animation = lib.mkOption {
        type = types.attrsOf (types.submodule ({ name, ... }: {
          options = {
            event = lib.mkOption {
              type = types.singleLineStr;
              default = name;
            };
            enable = lib.mkOption {
              type = types.bool;
              default = true;
            };
            duration = lib.mkOption { type = types.ints.positive; };
            curve = lib.mkOption {
              type = types.enum
                ((builtins.attrNames cfg.bezierCurve) ++ [ "default" ]);
              default = "default";
            };
            style = lib.mkOption {
              type = types.nullOr types.singleLineStr;
              default = null;
            };
          };
        }));
        default = { };
        description = lib.mdDoc ''
          An attribute set of animations rules.
        '';
        example = lib.literalExpression ''
          {
            workspaces = {
              effect = "slide";
              enable = true;
              duration = 8;
              curve = "default";
            }
          }
        '';
      };

      defaultBezierCurves = lib.mkOption {
        type =
          types.attrsOf (types.listOf (types.oneOf [ types.float types.int ]));
        readOnly = true;
        default = defaultBezierCurves;
        defaultText = lib.literalExpression
          (lib.generators.toPretty { newlines = true; } defaultBezierCurves);
        description = lib.mdDoc ''
          Read-only value containing an attrset of bezier curves to be included in
          the `bezierCurve` option by default.

          Curves are copied from <https://easings.net>.
        '';
      };

      bezierCurve = lib.mkOption {
        type =
          types.attrsOf (types.listOf (types.oneOf [ types.float types.int ]));
        default = defaultBezierCurves;
        description = lib.mdDoc ''
          An attribute set of bezier curves.
        '';
        example = lib.literalExpression ''
          {
            easeInSine = [0.12 0 0.39 0];
            easeOutSine = [0.61 1 0.88 1];
            easeInOutSine = [0.37 0 0.63 1];

            easeInQuad = [0.11 0 0.5 0];
            easeOutQuad = [0.5 1 0.89 1];
            easeInOutQuad = [0.45 0 0.55 1];
          }
        '';
      };
    };
  };
  config = let
    millisToDecis = x: x / 100;

    stringifyAnimation =
      { event, enable ? true, duration, curve ? "default", style ? null, }:
      "${event}, ${if enable then "1" else "0"}, ${
        toString (millisToDecis duration)
      }, ${curve}${lib.optionalString (style != null) ", ${style}"}";

    stringifyBezier = name: points:
      "${name}, ${lib.concatStringsSep ", " (map toString points)}";
  in {
    wayland.windowManager.hyprland.config.animations = {
      bezier = lib.mapAttrsToList stringifyBezier cfg.bezierCurve;
      animation = lib.mapAttrsToList (_: stringifyAnimation) cfg.animation;
    };
  };
}

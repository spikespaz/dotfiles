# This package is a single CSS file that's intended to be used from a third-party Discord client.
# The `text` of the file contains the metadata for the theme, and imports the remote URL of the stylesheet.
# In the metadata comment, the default values for the theme's variables are provided.
# These may be outdated at any given time, so it is recommended to check the remote stylesheet when customizing.
# Customize by overriding this derivation and providing custom attributes via `overrideVariables`.
let
  defaultUrl =
    "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Themes/DiscordRecolor/DiscordRecolor.css";
in { lib, writeTextFile, themeName ? "default", recolorUrl ? defaultUrl
, overrideVariables ? { } }:
let
  mkRecolorTheme = vars:
    let
      mkCssValue = expr:
        if lib.isString expr then
          ''"${expr}"''
        else if lib.isBool expr then
          if expr then "1" else "0"
        else if lib.isInt expr then
          toString expr
        else if lib.isList expr then
          lib.concatMapStringsSep ", " mkCssValue expr
        else
          abort ''
            Expression cannot be converted to a CSS value.
            Valid Nix types: int, string, list.
          '';
      mkCssVarLines =
        lib.mapAttrsToList (name: value: "--${name}: ${mkCssValue value};");
    in ''
      :root {
        ${lib.concatStringsSep "\n  " (mkCssVarLines vars)}
      }
    '';
in writeTextFile {
  name = "discord-recolor-${themeName}.css";
  text = ''
    /**
      * @name DiscordRecolor (${themeName})
      * @description Allows you to customize Discord's native Color Scheme
      * @author DevilBro
      * @version 1.0.0
      * @authorId 278543574059057154
      * @invite Jx3TjNS
      * @donate https://www.paypal.me/MircoWittrien
      * @patreon https://www.patreon.com/MircoWittrien
      * @website https://mwittrien.github.io/
      * @source https://github.com/mwittrien/BetterDiscordAddons/tree/master/Themes/DiscordRecolor/
      *
      * @var checkbox    settingsicons_s             "User Settings Icons"                            1
      * @var text        font_s                      "General Font"                                   "gg sans", "Noto Sans"
      * @var text        accentcolor_s               "Blurple Color: [default] = 88, 101, 242"        88,  101, 242
      * @var text        accentcolor2_s              "Boost Pink Color: [default] = 255, 115, 250"    255, 115, 250
      * @var text        linkcolor_s                 "Link Color: [default] = 0, 176, 244"            0,   176, 244
      * @var text        mentioncolor_s              "Mentioned Color: [default] = 250, 166, 26"      250, 166, 26
      * @var text        successcolor_s              "Success Color: [default] = 59, 165, 92"         59,  165, 92
      * @var text        warningcolor_s              "Warning Color: [default] = 250, 166, 26"        250, 166, 26
      * @var text        dangercolor_s               "Danger Color: [default] = 237, 66, 69"          237, 66,  69
      * @var text        textbrightest_s             "Text Color 1: [default] = 255, 255, 255"        255, 255, 255
      * @var text        textbrighter_s              "Text Color 2: [default] = 220, 221, 222"        222, 222, 222
      * @var text        textbright_s                "Text Color 3: [default] = 185, 187, 190"        185, 185, 185
      * @var text        textdark_s                  "Text Color 4: [default] = 142, 146, 151"        140, 140, 140
      * @var text        textdarker_s	               "Text Color 5: [default] = 114, 118, 125"        115, 115, 115
      * @var text        textdarkest_s               "Text Color 6: [default] = 79, 84, 92"           80,  80,  80
      * @var text        backgroundaccent_s          "Background Accent: [default] = 64, 68, 75"      50,  50,  50
      * @var text        backgroundprimary_s         "Background 1: [default] = 54, 57, 63"           30,  30,  30
      * @var text        backgroundsecondary_s       "Background 2: [default] = 47, 49, 54"           20,  20,  20
      * @var text        backgroundsecondaryalt_s    "Background 3: [default] = 41, 43, 47"           15,  15,  15
      * @var text        backgroundtertiary_s        "Background 4: [default] = 32, 34, 37"           10,  10,  10
      * @var text        backgroundfloating_s        "Background Elevated: [default] = 24, 25, 28"    0,   0,   0
    */

    @import url(${recolorUrl});

    ${mkRecolorTheme overrideVariables}
  '';
  passthru = { inherit recolorUrl overrideVariables; };
}

{ rgb }:
let
  colors = {
    dark0_hard = rgb 29 32 33; # #1d2021, 234
    dark0 = rgb 40 40 40; # #282828, 235
    dark0_soft = rgb 50 48 47; # #32302f, 236
    dark1 = rgb 60 56 54; # #3c3836, 237
    dark2 = rgb 80 73 69; # #504945, 239
    dark3 = rgb 102 92 84; # #665c54, 241
    dark4 = rgb 124 111 100; # #7c6f64, 243
    dark4_256 = rgb 124 111 100; # #7c6f64, 243

    gray_245 = rgb 146 131 116; # #928374, 245
    gray_244 = rgb 146 131 116; # #928374, 244

    light0_hard = rgb 249 245 215; # #f9f5d7, 230
    light0 = rgb 253 244 193; # #fbf1c7, 229
    light0_soft = rgb 242 229 188; # #f2e5bc, 228
    light1 = rgb 235 219 178; # #ebdbb2, 223
    light2 = rgb 213 196 161; # #d5c4a1, 250
    light3 = rgb 189 174 147; # #bdae93, 248
    light4 = rgb 168 153 132; # #a89984, 246
    light4_256 = rgb 168 153 132; # #a89984, 246

    bright_red = rgb 251 73 52; # #fb4934, 167
    bright_green = rgb 184 187 38; # #b8bb26, 142
    bright_yellow = rgb 250 189 47; # #fabd2f, 214
    bright_blue = rgb 131 165 152; # #83a598, 109
    bright_purple = rgb 211 134 155; # #d3869b, 175
    bright_aqua = rgb 142 192 124; # #8ec07c, 108
    bright_orange = rgb 254 128 25; # #fe8019, 208

    neutral_red = rgb 204 36 29; # #cc241d, 124
    neutral_green = rgb 152 151 26; # #98971a, 106
    neutral_yellow = rgb 215 153 33; # #d79921, 172
    neutral_blue = rgb 69 133 136; # #458588, 66
    neutral_purple = rgb 177 98 134; # #b16286, 132
    neutral_aqua = rgb 104 157 106; # #689d6a, 72
    neutral_orange = rgb 214 93 14; # #d65d0e, 166

    faded_red = rgb 157 0 6; # #9d0006, 88
    faded_green = rgb 121 116 14; # #79740e, 100
    faded_yellow = rgb 181 118 20; # #b57614, 136
    faded_blue = rgb 7 102 120; # #076678, 24
    faded_purple = rgb 143 63 113; # #8f3f71, 96
    faded_aqua = rgb 66 123 88; # #427b58, 66
    faded_orange = rgb 175 58 3; # #af3a03, 130
  };

  palettes = {
    light = {
      fg = colors.dark1;
      fg0 = colors.dark0;
      fg1 = colors.dark1;
      fg2 = colors.dark2;
      fg3 = colors.dark3;
      fg4 = colors.dark4;

      bg = colors.light0;
      bg0_hard = colors.light0_hard;
      bg0_soft = colors.light0_soft;
      bg0 = colors.light0;
      bg1 = colors.light1;
      bg2 = colors.light2;
      bg3 = colors.light3;
      bg4 = colors.light4;

      fg_red = colors.faded_red;
      fg_green = colors.faded_green;
      fg_yellow = colors.faded_yellow;
      fg_blue = colors.faded_blue;
      fg_purple = colors.faded_purple;
      fg_aqua = colors.faded_aqua;
      fg_orange = colors.faded_orange;
      fg_gray = colors.dark4;

      hl_red = colors.neutral_red;
      hl_green = colors.neutral_green;
      hl_yellow = colors.neutral_yellow;
      hl_blue = colors.neutral_blue;
      hl_purple = colors.neutral_purple;
      hl_aqua = colors.neutral_aqua;
      hl_orange = colors.neutral_orange;
      hl_gray = colors.gray_244;

      gray = colors.gray_244;
    };
    dark = {
      fg = colors.light1;
      fg0 = colors.light0;
      fg1 = colors.light1;
      fg2 = colors.light2;
      fg3 = colors.light3;
      fg4 = colors.light4;

      bg = colors.dark0;
      bg0_hard = colors.dark0_hard;
      bg0_soft = colors.dark0_soft;
      bg0 = colors.dark0;
      bg1 = colors.dark1;
      bg2 = colors.dark2;
      bg3 = colors.dark3;
      bg4 = colors.dark4;

      fg_red = colors.bright_red;
      fg_green = colors.bright_green;
      fg_yellow = colors.bright_yellow;
      fg_blue = colors.bright_blue;
      fg_purple = colors.bright_purple;
      fg_aqua = colors.bright_aqua;
      fg_orange = colors.bright_orange;
      fg_gray = colors.gray_245;

      hl_red = colors.neutral_red;
      hl_green = colors.neutral_green;
      hl_yellow = colors.neutral_yellow;
      hl_blue = colors.neutral_blue;
      hl_purple = colors.neutral_purple;
      hl_aqua = colors.neutral_aqua;
      hl_orange = colors.neutral_orange;
      hl_gray = colors.light4;

      gray = colors.gray_245;
    };
  };

  indexed = let mk = index: color: { inherit index color; };
  in with colors; [
    (mk 234 dark0_hard)
    (mk 235 dark0)
    (mk 236 dark0_soft)
    (mk 237 dark1)
    (mk 239 dark2)
    (mk 241 dark3)
    (mk 243 dark4)
    (mk 243 dark4_256)

    (mk 245 gray_245)
    (mk 244 gray_244)

    (mk 230 light0_hard)
    (mk 229 light0)
    (mk 228 light0_soft)
    (mk 223 light1)
    (mk 250 light2)
    (mk 248 light3)
    (mk 246 light4)
    (mk 246 light4_256)

    (mk 167 bright_red)
    (mk 142 bright_green)
    (mk 214 bright_yellow)
    (mk 109 bright_blue)
    (mk 175 bright_purple)
    (mk 108 bright_aqua)
    (mk 208 bright_orange)

    (mk 124 neutral_red)
    (mk 106 neutral_green)
    (mk 172 neutral_yellow)
    (mk 66 neutral_blue)
    (mk 132 neutral_purple)
    (mk 72 neutral_aqua)
    (mk 166 neutral_orange)

    (mk 88 faded_red)
    (mk 100 faded_green)
    (mk 136 faded_yellow)
    (mk 24 faded_blue)
    (mk 96 faded_purple)
    (mk 66 faded_aqua)
    (mk 130 faded_orange)
  ];
in {
  inherit colors indexed;
  inherit (palettes) light dark;
}

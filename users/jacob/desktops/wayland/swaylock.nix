{
  config,
  pkgs,
  lib,
  ...
}: let
  # package = pkgs.swaylock-effects.overrideAttrs (old: rec {
  #   version = "1.6.11";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "jirutka";
  #     repo = "swaylock-effects";
  #     rev = "v${version}";
  #     sha256 = "sha256-MKmWVYssO9HAcP5uqwpy9kDa6/kfZyV2NI7ibozt7Ug=";
  #   };
  # });
  package = pkgs.swaylock-effects;
  # withRandomImage = pkgs.writeShellScriptBin "swaylock" ''
  #   wallpapers='${config.home.sessionVariables.USER_WALLPAPERS_DIRECTORY}'
  #   if [ -n "$wallpapers" ]; then
  #     image="$(
  #       find "$wallpapers" \
  #         -type f \
  #         -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \
  #         | shuf -n1
  #     )"
  #     ${lib.getExe package} -i "$image" $@
  #   else
  #     ${lib.getExe package} $@
  #   fi
  # '';
in {
  programs.swaylock.enable = true;
  # programs.swaylock.package = withRandomImage;
  programs.swaylock.package = package;

  programs.swaylock.settings = let
    ### Indicator Colors ###
    bg_opacity = "7f"; # 50%
    # fg_opacity = "bf";  # 75%
    fg_opacity = "b2"; # 70%

    inside_color = "0f0f0f";
    text_color = "dedede";
    line_color = "000000";
    background = "282828";

    ### Ring Colors ###
    # <https://materialui.co/colors/>

    ## Normal
    # cyan_500 = "00BCD4";
    teal_500 = "009688";
    ## Normal Keypress
    # cyan_300 = "4DD0E1";
    teal_300 = "4DB6AC";
    ## Normal Backspace
    # cyan_900 = "006064";
    teal_900 = "004D40";
    ## Capslock
    orange_500 = "FF9800";
    ## Capslock Keypress
    orange_300 = "FFB74D";
    ## Capslock Backspace
    orange_900 = "E65100";
    ## Verifying
    # purple_a100 = "EA80FC";
    purple_300 = "BA68C8";
    ## Cleared
    green_a700 = "00C853";
    ## Incorrect
    # red_a700 = "D50000";
    # deep_orange_a400 = "FF3D00";
    deep_orange_600 = "F4511E";
  in {
    ### Behavior ###

    # ignore-empty-password = true;
    # daemonize = true;
    # grace = 5;  # Specify when auto-lock
    # grace-no-mouse = true;
    indicator = true;
    show-failed-attempts = true;

    ### Effect ###

    fade-in = 0.25; # s
    screenshots = true;
    effect-blur = "15x3";
    # causes a white border around the edges of the screen
    # effect-scale = 0.5;
    effect-vignette = "0.25:0.5";
    # for when a random wallpaper isn't set,
    # and a new monitor is connected
    color = background;

    ### Indicator ###

    clock = true;
    timestr = "%-I:%M:%S %p";
    datestr = "%a, %b %-d, %Y";
    indicator-idle-visible = true;
    indicator-caps-lock = true;
    indicator-radius = 80;
    indicator-thickness = 6;

    ### Text ###

    font = "Ubuntu";
    font-size = 22;
    text-color = text_color;
    text-clear-color = text_color;
    text-caps-lock-color = text_color;
    text-ver-color = text_color;
    text-wrong-color = text_color;

    ### Background ###

    inside-color = inside_color + bg_opacity;
    inside-clear-color = inside_color + bg_opacity;
    inside-caps-lock-color = inside_color + bg_opacity;
    inside-ver-color = inside_color + bg_opacity;
    inside-wrong-color = inside_color + bg_opacity;

    ### Line ###

    separator-color = line_color;
    line-color = line_color;
    line-clear-color = line_color;
    line-caps-lock-color = line_color;
    line-ver-color = line_color;
    line-wrong-color = line_color;

    ### Ring ###

    ring-color = teal_500 + fg_opacity;
    key-hl-color = teal_300 + fg_opacity;
    bs-hl-color = teal_900 + fg_opacity;

    ring-caps-lock-color = orange_500 + fg_opacity;
    caps-lock-key-hl-color = orange_300 + fg_opacity;
    caps-lock-bs-hl-color = orange_900 + fg_opacity;

    ring-ver-color = purple_300 + fg_opacity;
    ring-clear-color = green_a700 + fg_opacity;
    ring-wrong-color = deep_orange_600 + fg_opacity;
  };

  # Hiding this at the end. This is just a quick fix for there being no
  # `package` option, as any configuration depending on knowing which
  # executable to use will need to be hand-written to use a specific package.
  # Note that because the original module is part of Home Manager,
  # to keep this simple, there is no attempt to prevent writing
  # `settings` if `enable` is `false`.
  imports = [
    ({
      config,
      pkgs,
      lib,
      ...
    }: let
      cfg = config.programs.swaylock;
    in {
      options = {
        programs.swaylock.enable = lib.mkEnableOption (lib.mdDoc ''
          Whether to install the specified package to `home.packages`.
        '');
        programs.swaylock.package = lib.mkPackageOption pkgs "swaylock" {
          example = lib.literalExpression "pkgs.swaylock-effects";
        };
      };
      config = lib.mkIf cfg.enable {
        home.packages = [cfg.package];
      };
    })
  ];
}

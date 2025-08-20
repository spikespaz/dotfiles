{ lib, pkgs, config, ... }: {
  home.packages =
    [ pkgs.monaspace pkgs.material-design-icons pkgs.nerd-fonts.symbols-only ];

  programs.rio.enable = true;
  programs.rio.settings = {
    shell = {
      program = "${lib.getExe config.programs.fish.package}";
      args = if pkgs.hostPlatform.isDarwin then [
        "--interactive"
        "--login"
      ] else
        [ "--interactive" ];
    };

    fonts.family = "Monaspace Neon";
    fonts.extras = [
      { family = "Symbols Nerd Font Mono"; }
      { family = "Material Design Icons"; }
    ];
    fonts.use-drawable-chars = true;
    fonts.size = 15;

    cursor.shape = "beam";
    cursor.blinking = true;
    padding-x = 6;
    padding-y = [ 2 2 ];
    theme = "gruvbox_dark_harder";
    window.opacity = 0.7;

    navigation.mode = "Plain";
    navigation.use-split = false;

    confirm-before-quit = false;

    renderer.performance = "Low";
    renderer.target-fps = 90;

    editor.program = "code";
  };

  xdg.configFile."rio/themes/gruvbox_dark_harder.toml".source = let
    inherit (lib.birdos.colors) grayRGB hexRGB';
    gb = lib.birdos.colors.formats.hexRGB'.gruvbox.colors;
    gray = percent: hexRGB' (grayRGB percent);
    dark_harder = gray 7.0e-2; # 7% of each channel
  in (pkgs.formats.toml { }).generate "gruvbox_dark_harder.toml" {
    colors = with gb; rec {
      background = dark_harder;
      foreground = light1;
      selection-background = light1;
      selection-foreground = dark_harder;

      cursor = foreground;

      black = dark2;
      blue = neutral_blue;
      cyan = neutral_aqua;
      green = neutral_green;
      magenta = neutral_purple;
      red = neutral_red;
      white = light1;
      yellow = neutral_yellow;

      dim-black = dark1;
      dim-blue = faded_blue;
      dim-cyan = faded_aqua;
      dim-green = faded_green;
      dim-magenta = faded_purple;
      dim-red = faded_red;
      dim-white = light2;
      dim-yellow = faded_yellow;

      light-black = dark3;
      light-blue = bright_blue;
      light-cyan = bright_aqua;
      light-green = bright_green;
      light-magenta = bright_purple;
      light-red = bright_red;
      light-white = light0;
      light-yellow = bright_yellow;
    };
  };
}

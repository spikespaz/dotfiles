{
  config,
  pkgs,
  lib,
  ...
}: {
  services.gammastep = {
    enable = true;
    tray = true;
    dawnTime = "6:30-8:00"; # 6:30 AM to 8:00 AM
    duskTime = "20:30-22:00"; # 8:30 PM to 10:00 PM
    provider = "geoclue2";
    temperature.day = 6500;
    temperature.night = 3700;
    settings.general = {
      fade = true;
      adjustment-method = "wayland";
    };
  };

  # TODO integrate this into slight
  xdg.configFile."gammastep/hooks/brightness.sh" = let
    slight = lib.getExe pkgs.slight;
    brightness.day = 90;
    brightness.transition = 60;
    brightness.night = 30;
    # to day from transition
    duration.day = "5s";
    # to transition from day
    duration.transition.day = "10s";
    # to transition from night
    duration.transition.night = "10s";
    # to night from transition
    duration.night = "20s";
  in {
    executable = true;
    source =
      (pkgs.writeShellScript "gammastep-brightness" ''
        set -eu

        exec >> /tmp/redshift-hooks.log 2>&1

        if [ "$1" = 'period-changed' ]; then
          case "$3" in
            daytime)
              target="${toString brightness.day}%"
              case "$2" in
                  transition)
                    ${slight} set -I "$target" -t ${duration.day}
                    ;;
                  night|none)
                    ${slight} set "$target"
                    ;;
                  *)
                    echo "unrecognized: $2"
                    ;;
              esac
              ;;
            transition)
              target="${toString brightness.transition}%"
              case "$2" in
                  daytime)
                    ${slight} set -D "$target" -t ${duration.transition.day}
                    ;;
                  night)
                    ${slight} set -I "$target" -t ${duration.transition.night}
                    ;;
                  none)
                    ${slight} set "$target"
                    ;;
                  *)
                    echo "unrecognized: $2"
                    ;;
              esac
              ;;
            night)
              target="${toString brightness.night}%"
              case "$2" in
                transition)
                  ${slight} set -D "$target" -t ${duration.night}
                  ;;
                daytime|none)
                  ${slight} set "$target"
                  ;;
                *)
                  echo "unrecognized: $2"
                  ;;
              esac
              ;;
          esac
        fi
      '')
      .outPath;
  };

  # <https://wiki.archlinux.org/title/redshift#Use_real_screen_brightness>
}

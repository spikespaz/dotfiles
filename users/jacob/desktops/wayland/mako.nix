{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    # Notification API
    pkgs.libnotify
  ];

  # firefox about:config alerts.useSystemBackend = off, restart, = on, restart
  # notification daemon
  programs.mako = {
    enable = true;
    anchor = "top-left";
    maxVisible = 3;
    sort = "+time";
    output = null;
    width = 300;
    height = 150;
    icons = true;
    iconPath = null;
    maxIconSize = 64;
    textColor = "#ffffffff";
    backgroundColor = "#282828bf";
    borderColor = "#bdae93ff";
    progressColor = "source #689d6aff";
    borderRadius = 3;
    borderSize = 2;
    margin = "10";
    padding = "5";
    defaultTimeout = 7;
    ignoreTimeout = false;
    layer = "overlay";
    font = "Ubuntu 10";
    format = "<b>%s</b>\\n%b";
    markup = true;
  };

  # <https://github.com/emersion/mako/blob/master/contrib/systemd/mako.service>
  systemd.user.services.mako = let
    package = config.programs.mako.package;
  in {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      Documentation = "man:mako(1)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecCondition = "${lib.getExe pkgs.bash} -c '[ -n \"$WAYLAND_DISPLAY\" ]'";
      ExecStart = lib.getExe package;
      ExecReload = "${package}/bin/makoctl reload";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}

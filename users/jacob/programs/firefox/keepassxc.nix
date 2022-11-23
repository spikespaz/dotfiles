# TODO maybe?
# <https://gist.github.com/dAnjou/b99f55de34b90246f381e71e3c8f9262>
# <https://github.com/keepassxreboot/keepassxc/issues/613>
{
  pkgs,
  lib,
  ...
}: {
  programs.firefox.extensions = [
    pkgs.nur.repos.rycee.firefox-addons.keepassxc-browser
  ];

  # This is for keepassxc-browser integration.
  # Needs the respective options changed in the GUI,
  # TODO set those options declaratively.
  systemd.user.services.keepassxc = {
    Unit = {
      Description = pkgs.keepassxc.meta.description;
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      KillMode = "process";
      # Environment = "PATH=${lib.makeBinPath [pkgs.systemd cfg.package]}";
      ExecStart = lib.getExe pkgs.keepassxc;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}

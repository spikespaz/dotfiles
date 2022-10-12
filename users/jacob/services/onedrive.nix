{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.onedrive # TODO: figure out how to start this with secrets
  ];

  systemd.user.services.onedrive = {
    Unit = {
      Description = pkgs.onedrive.meta.description;
      Documentation = "https://github.com/abraunegg/onedrive";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };

    Service = {
      # Commented out hardenings are disabled because they don't work out of the box.
      # If you know what you are doing please try to enable them.
      ProtectSystem = "full";
      #PrivateDevices = true;
      ProtectHostname = true;
      #ProtectClock = true;
      ProtectKernelTunables = true;
      #ProtectKernelModules = true;
      #ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.onedrive)
        "--monitor"
        "--confdir=${config.xdg.configHome}/onedrive"
      ];
      # User = config.home.username;
      # Group = "users";
      Restart = "on-failure";
      RestartSec = 3;
      RestartPreventExitStatus = 3;
    };

    Install = {
      WantedBy = ["multi-user.target"];
    };
  };
}

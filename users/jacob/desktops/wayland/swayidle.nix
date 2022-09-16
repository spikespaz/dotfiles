{ pkgs, hmModules, ... }: {
  imports = [
    hmModules.dotpkgs.idlehack
  ];

  home.packages = [
    pkgs.swayidle
  ];

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # write the config to the expected location and
  # execute from hyprland because the systemd service doesn't work
  xdg.configFile."swayidle/config".text = let
    # the swayidle path in the nixpkg is wrong
    # <https://github.com/NixOS/nixpkgs/pull/189452>
    # swaylock = lib.getExe pkgs.swaylock-effects;
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    auto_lock.timeout = 2 * 60;
    auto_lock.grace = 30;
    forced_lock.grace = 5;
  in ''
    timeout ${toString auto_lock.timeout} '${swaylock} -f --grace ${toString auto_lock.grace}'
    before-sleep '${swaylock} -f'
    lock '${swaylock} -f --grace ${toString forced_lock.grace} --grace-no-mouse'
  '';
}

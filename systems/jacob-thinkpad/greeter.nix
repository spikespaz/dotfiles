{ configs, lib, pkgs, nixpkgs, ... }: {
  environment.systemPackages = [
    pkgs.greetd.tuigreet
  ];

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = ''
          ${lib.getExe pkgs.greetd.tuigreet} \
            --time \
            --remember \
            --remember-user-session \
            --asterisks \
            --cmd 'Hyprland &>/dev/null'
        '';
        user = "greeter";
      };
    };
  };
}

{
  lib,
  pkgs,
  ...
}: let
  amdctl = pkgs.stdenv.mkDerivation rec {
    name = "amdctl";
    version = "0.11";
    nativeBuildInputs = [pkgs.gnumake];
    installPhase = ''
      runHook preInstall

      ${lib.getExe pkgs.gnumake}
      install -Dm555 ./amdctl $out/bin/amdctl

      runHook postInstall
    '';
    src = pkgs.fetchFromGitHub {
      owner = "kevinlekiller";
      repo = "amdctl";
      rev = "v${version}";
      sha256 = "sha256-2wBk/9aAD7ARMGbcVxk+CzEvUf8U4RS4ZwTCj8cHNNo=";
    };
  };
in {
  # <https://github.com/kevinlekiller/amdctl/>
  environment.systemPackages = [
    amdctl
  ];

  boot.kernelModules = ["msr"];
  boot.kernelParams = ["msr.allow_writes=on"];

  systemd.services.undervolt = let
    default = {
      p0 = 1218;
      p1 = 950;
      p2 = 912;
    };
    offset = {
      p0 = -100;
      p1 = -100;
      p2 = -100;
    };
  in {
    serviceConfig.Type = "notify";
    description = "control undervolt with amdctl";
    documentation = ["https://github.com/kevinlekiller/amdctl"];
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    script = ''
      sed_script='s/[A-z ]\+\([[:digit:]]\+\)[A-z ]\+\([[:digit:]]\+\)mV.*/\1/'

      p0_vid=$(${lib.getExe amdctl} -p0 -u${toString (default.p0 + offset.p0)} \
        | sed "$sed_script")
      p1_vid=$(${lib.getExe amdctl} -p1 -u${toString (default.p1 + offset.p1)} \
        | sed "$sed_script")
      p2_vid=$(${lib.getExe amdctl} -p2 -u${toString (default.p2 + offset.p2)} \
        | sed "$sed_script")

      ${lib.getExe amdctl} -p0 -v$p0_vid
      ${lib.getExe amdctl} -p1 -v$p1_vid
      ${lib.getExe amdctl} -p2 -v$p2_vid

      echo "NOTIFY_SOCKET=''${NOTIFY_SOCKET-}"
      if [ -n "''${NOTIFY_SOCKET-}" ]; then
        ${pkgs.systemd}/bin/systemd-notify --ready
        ## systemd-notify always returns nonzero, but the message is sent anyway
        # if [ "$(systemd-notify --ready)" ]; then
        #   echo "Notified systemd that this unit is ready."
        # else
        #   echo 'Error: failed to notify systemd that we are ready!'
        #   exit 30
        # fi
      fi
    '';
  };
}

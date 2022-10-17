{
  lib,
  pkgs,
  ...
}: let
  amdctl = pkgs.stdenv.mkDerivation {
    name = "amdctl";
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
      rev = "f302b80910b3a88e25ceb62be31fd6d0708dc3d7";
      sha256 = "sha256-5cIJVAZXBnQDchZNhGFxCUww9JCRjTHsn7Ze5dD6JOo=";
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
    undervolt = {
      p0 = default.p0 - 50;
      p1 = default.p1 - 50;
      p2 = default.p2 - 100;
    };
  in {
    serviceConfig.Type = "notify";
    description = "control undervolt with amdctl";
    documentation = ["https://github.com/kevinlekiller/amdctl"];
    # wants = [];
    after = ["multi-user.target"];
    # before = [];
    # partOf = [];
    # requires = [];
    wantedBy = ["multi-user.target"];
    script = ''
      sed_script='s/[A-z ]\+\([[:digit:]]\+\)[A-z ]\+\([[:digit:]]\+\)mV.*/\1/'

      p0_vid=$(${lib.getExe amdctl} -p0 -u${toString undervolt.p0} \
        | sed "$sed_script")
      p1_vid=$(${lib.getExe amdctl} -p1 -u${toString undervolt.p1} \
        | sed "$sed_script")
      p2_vid=$(${lib.getExe amdctl} -p2 -u${toString undervolt.p2} \
        | sed "$sed_script")

      ${lib.getExe amdctl} -p1 -v$p0_vid
      ${lib.getExe amdctl} -p1 -v$p1_vid
      ${lib.getExe amdctl} -p1 -v$p2_vid

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

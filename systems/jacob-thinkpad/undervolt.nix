{ lib, pkgs, ... }:
let
  amdctl = pkgs.stdenv.mkDerivation rec {
    name = "amdctl";
    version = "0.11";
    nativeBuildInputs = [ pkgs.gnumake ];
    installPhase = ''
      runHook preInstall

      make
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
  environment.systemPackages = [ amdctl ];

  boot.kernelModules = [ "msr" ];
  boot.kernelParams = [ "msr.allow_writes=on" ];

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
    targets = [ "multi-user.target" "post-resume.target" ];
  in {
    serviceConfig.Type = "oneshot";
    description = "control undervolt with amdctl";
    documentation = [ "https://github.com/kevinlekiller/amdctl" ];
    after = targets;
    wantedBy = targets;
    script = ''
      set -eu

      get_vid() {
        ${lib.getExe amdctl} -p$1 -u$2 \
          | sed -E 's;^.+vid ([0-9]+).+$;\1;'
      }

      p0_vid=$(get_vid 0 ${toString (default.p0 + offset.p0)})
      p1_vid=$(get_vid 1 ${toString (default.p1 + offset.p1)})
      p2_vid=$(get_vid 2 ${toString (default.p2 + offset.p2)})

      echo "P-State 0 VID = $p0_vid"
      echo "P-State 1 VID = $p1_vid"
      echo "P-State 2 VID = $p2_vid"

      ${lib.getExe amdctl} -p0 -v$p0_vid
      ${lib.getExe amdctl} -p1 -v$p1_vid
      ${lib.getExe amdctl} -p2 -v$p2_vid
    '';
  };
}

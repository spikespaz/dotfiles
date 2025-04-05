{ self, lib, pkgs, ... }:
let
  nuphy-udev-rules = pkgs.stdenvNoCC.mkDerivation {
    name = "nuphy-udev-rules";
    version = "332710cd961e4cddaa70009a4a559b6e70a66726";
    src = pkgs.fetchFromGitHub {
      owner = "Z3R0-CDS";
      repo = "nuphy-linux";
      rev = nuphy-udev-rules.version;
      hash = "sha256-8Ss74o9kgTzUhGNvll0GYBvUx6sGvn6Mq5DDFlWHbDs=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -D nuphy.rules $out/lib/udev/rules.d/51-qmk-nuphy.rules
      runHook postInstall
    '';
    meta = {
      homepage = "https://github.com/Z3R0-CDS/nuphy-linux";
      description = "Unofficial udev rules for Nuphy keyboard devices";
      platforms = lib.platforms.linux;
    };
  };
in {
  imports = [ self.nixosModules.qmk-devices ];
  hardware.keyboard.qmk.enable = true;
  # udev rules from `pkgs.via` are too permissive
  services.udev.packages = [ nuphy-udev-rules ];

  # The `productId` changed after
  hardware.keyboard.qmk.extraDevices = [{
    name = "NuPhy Air75 V2.1";
    vendorId = "19f5";
    productId = "3246";
  }];
}

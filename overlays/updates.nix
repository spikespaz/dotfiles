pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  # keepassxc = pkgs0.keepassxc.overrideAttrs (self: super: {
  #   patches = super.patches or [ ] ++ [
  #     (pkgs.fetchpatch {
  #       url =
  #         "https://github.com/keepassxreboot/keepassxc/commit/f93adaa854b859dc0bda4ad3422f6f98b269f744.diff";
  #       hash = "sha256-D5HRUOonLZOmjmLevSzh+OaQ8pR2E4yfgnEJwFWMP0I=";
  #     })
  #   ];
  # });

  vscode-marketplace = pkgs0.vscode-marketplace // {
    slint = pkgs0.vscode-marketplace.slint // {
      slint = pkgs0.vscode-marketplace.slint.slint.overrideAttrs (self: super: {
        postInstall = super.postInstall or "" + ''
          extBin=$out/share/vscode/extensions/slint.slint/bin/
          rm $out/share/vscode/extensions/slint.slint/bin/slint-lsp-*
          cp ${lib.getExe pkgs.slint-lsp} \
            $extBin/slint-lsp-${pkgs.hostPlatform.config}
        '';
      });
    };
  };

  swaylock-effects = pkgs0.swaylock-effects.overrideAttrs (self: super: {
    patches = super.patches or [ ] ++ [
      # Pull request #49 for proper fprintd support.
      (pkgs.fetchpatch {
        url =
          "https://patch-diff.githubusercontent.com/raw/jirutka/swaylock-effects/pull/49.diff";
        hash = "sha256-hbPRFiKFxC2+TtadDSdlrgZlP/9/VHwasGZiCa7sT3A=";
      })
    ];
    mesonFlags = super.mesonFlags ++ [ "-Dfingerprint=enabled" ];
    # The `build.meson` does not use `pkg-config` for DBus interfaces,
    # therefor `PKG_CONFIG_DBUS_1_INTERFACES_DIR` does not apply.
    # <https://github.com/jirutka/swaylock-effects/pull/49#issuecomment-1932220922>
    postPatch = let
      dbusInterfacesDir = (pkgs.symlinkJoin {
        name = "${self.pname}-${self.version}_dbus-interfaces-dir";
        paths = self.buildInputs;
        pathsToLink = [ "share/dbus-1/interfaces" ];
      }) + "/share/dbus-1/interfaces";
    in super.postPatch or "" + ''
      sed -i 's@/usr/share/dbus-1/interfaces@${dbusInterfacesDir}@g' \
        fingerprint/meson.build
    '';
    buildInputs = super.buildInputs ++ (with pkgs; [ dbus fprintd ]);
  });
}

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

  # TODO pull request
  shotcut = pkgs0.shotcut.overrideAttrs (self: super: {
    buildInputs = super.buildInputs or [ ] ++ [ pkgs.qt6.qtwayland ];
  });

  # This is used by the HM module `qt.nix`. The path there is hard-coded to
  # `qt6Packages.qt6ct` and can't be changed with a `package` option.
  # That is the reason this is an overlay, and not a separate package.
  # ---
  # Does someone know the difference between `kdePackages` and `qt6Packages`?
  # I have tried to find where `kdePackages` is defined and all I can find
  # (that isn't direct usage) is a scope splice.
  # It seems that `qt6Packages` is the earliest instantiation of all the
  # derivations within, and that `kdePackages` probably inherits from it
  # (the scope splice I mentioned).
  # But, `qt6Packages` is not listed in the (unstable) package search
  # (it is in stable).
  # Some Home Manager modules are hard-coded to use `qt6Packages`,
  # but that namespace is (now) missing on the Package Search webpage.
  qt6Packages = pkgs0.qt6Packages // {
    qt6ct = pkgs0.qt6Packages.qt6ct.overrideAttrs (self: super: {
      patches = super.patches or [ ] ++ [
        (pkgs.fetchpatch {
          url =
            "https://patch-diff.githubusercontent.com/raw/trialuser02/qt6ct/pull/43.diff";
          hash = "sha256-U0Mb7Quoh8V6Wix42ILobE4L8/2BCinxhPkEI50+T/w=";
        })
        (pkgs.fetchpatch {
          url =
            "https://patch-diff.githubusercontent.com/raw/trialuser02/qt6ct/pull/44.diff";
          hash = "sha256-fafLjzPFaIBwMJuFUWISZepPypr6P3SHm6+vIuEdTIY=";
        })
      ];
      buildInputs = super.buildInputs or [ ] ++ (with pkgs.kdePackages; [
        qtdeclarative
        kconfig
        kcolorscheme
        kiconthemes
      ]);
      # Original inputs removed, switch to cmake.
      nativeBuildInputs = with pkgs;
        with pkgs.kdePackages; [
          cmake
          qttools
          wrapQtAppsHook
        ];
      cmakeFlags = [
        "-DPLUGINDIR=${
          placeholder "out"
        }/${pkgs.kdePackages.qtbase.qtPluginPrefix}"
      ];
    });
  };

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

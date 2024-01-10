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

  alacritty = pkgs0.alacritty.overrideAttrs (self: super: {
    version = "0.13.1";
    src = pkgs.fetchFromGitHub {
      owner = "alacritty";
      repo = "alacritty";
      rev = "v${self.version}";
      hash = "sha256-Nn/G7SkRuHXRSRgNjlmdX1G07sp7FPx8UyAn63Nivfg=";
    };
    cargoDeps = super.cargoDeps.overrideAttrs {
      inherit (self) src;
      outputHash = "sha256-ae+PuTNq2sDwxjw9Ff1aCpFxxWfvPPCsQ7RKQ7mVCiA=";
    };
  });

  vscode-marketplace = pkgs0.vscode-marketplace // {
    slint = pkgs0.vscode-marketplace.slint // {
      slint = pkgs0.vscode-marketplace.slint.slint.overrideAttrs (self: super: {
        postInstall = (super.postInstall or "") + ''
          extBin=$out/share/vscode/extensions/slint.slint/bin/
          rm $out/share/vscode/extensions/slint.slint/bin/slint-lsp-*
          cp ${lib.getExe pkgs.slint-lsp} \
            $extBin/slint-lsp-${pkgs.hostPlatform.config}
        '';
      });
    };
  };
}

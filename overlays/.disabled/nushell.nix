pkgs: pkgs0: {
  nushell = pkgs0.nushell.overrideAttrs (self: super: {
    version = "unstable_03-17-2022";
    src = pkgs.fetchFromGitHub {
      owner = "nushell";
      repo = "nushell";
      rev = "3f224db990f01b485695cd12dcd46d0db6276e5c";
      sha256 = "sha256-+OGd2A7mCmXhx7MXG94Lcveja0uOl7bRE6i3S0YjPUU=";
    };
    # Doesn't care about this?
    cargoSha256 = pkgs.lib.fakeSha256;
    # This isn't mentioned:
    # <https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md>
    cargoDeps = super.cargoDeps.overrideAttrs {
      name = "${self.pname}-${self.version}-vendor.tar.gz";
      inherit (self) src;
      outputHash = "sha256-FZM9KcwUart+xXeSXUTo8iv2IkwM8LQ/vAltk9SqdUE=";
    };
    buildInputs = super.buildInputs or [ ] ++ [ pkgs.procps ];
  });
}

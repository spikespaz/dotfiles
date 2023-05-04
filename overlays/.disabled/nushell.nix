final: prev: {
  nushell = prev.nushell.overrideAttrs (old: rec {
    version = "unstable_03-17-2022";
    src = final.fetchFromGitHub {
      owner = "nushell";
      repo = "nushell";
      rev = "3f224db990f01b485695cd12dcd46d0db6276e5c";
      sha256 = "sha256-+OGd2A7mCmXhx7MXG94Lcveja0uOl7bRE6i3S0YjPUU=";
    };
    # Doesn't care about this?
    cargoSha256 = final.lib.fakeSha256;
    # This isn't mentioned:
    # <https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md>
    cargoDeps = old.cargoDeps.overrideAttrs (final.lib.const {
      name = "${old.pname}-${version}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-FZM9KcwUart+xXeSXUTo8iv2IkwM8LQ/vAltk9SqdUE=";
    });
    buildInputs = old.buildInputs or [ ] ++ [ final.procps ];
  });
}
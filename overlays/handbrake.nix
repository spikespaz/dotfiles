final: prev: let
  inherit (final) lib;
in {
  # <https://github.com/NixOS/nixpkgs/pull/212306>
  # <https://github.com/laalsaas/nixpkgs/commit/c8bb1b66fd21c1d8d37ec8a177d01a7512a30a22>
  handbrake = prev.handbrake.overrideAttrs (old: let
    version = "1.6.1";

    src = final.fetchFromGitHub {
      owner = "HandBrake";
      repo = "HandBrake";
      rev = version;
      sha256 = "sha256-0MJ1inMNA6s8l2S0wnpM2c7FxOoOHxs9u4E/rgKfjJo=";
    };

    ffmpegVersion = "5.1.1";
    ffmpegPatchesDir = "${src}/contrib/ffmpeg";
    ffmpegCustom = final.ffmpeg_5-full.overrideAttrs (old: {
      version = ffmpegVersion;
      src = final.fetchurl {
        url = "https://www.ffmpeg.org/releases/ffmpeg-${ffmpegVersion}.tar.bz2";
        hash = "sha256-zQ4W+QNCEmbVzN3t97g7nldUrvS596fwbOnkyALwVFs=";
      };
      patches = lib.pipe ffmpegPatchesDir [
        builtins.readDir
        (lib.filterAttrs (
          name: type:
            type == "regular" && builtins.match ".+\\.patch" name != null
        ))
        (lib.mapAttrsToList (name: _: "${ffmpegPatchesDir}/${name}"))
        (patches: old.patches or [] ++ patches)
      ];
    });

    ffmpegOldName = "ffmpeg-full-4.4.1";
    ffmpegOld = lib.findSingle (p: p.name == ffmpegOldName) null null old.buildInputs;

    buildInputs = (lib.remove ffmpegOld old.buildInputs) ++ [ffmpegCustom final.svt-av1];
  in {
    inherit version src buildInputs;
  });
}

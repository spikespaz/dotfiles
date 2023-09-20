# 1. If a plugin name starts with `zsh-`, leave it alone.
# 2. If a plugin name ends with `-zsh`, remove it and prepend `zsh-`.
# 3. If a plugin name does not contain `zsh`, prefix with `zsh-`.
# 4. In all cases, leave `pname` so that it
#    matches the original name of the plugin.
{ lib, fetchFromGitHub }:
let
  mkZshPlugin = { pname, version, meta ? { }, src }:
    src.overrideAttrs (self: super: {
      inherit pname version;
      name = "${pname}-${version}";
      meta = super.meta
        // (lib.optionalAttrs (src ? meta && src.meta ? homepage) {
          homepage = src.meta.homepage;
        }) // meta;
    });
in {
  zsh-autosuggestions = mkZshPlugin rec {
    pname = "zsh-autosuggestions";
    version = "v0.7.0";
    src = fetchFromGitHub {
      owner = "zsh-users";
      repo = pname;
      rev = version;
      hash = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
    };
    meta.license = lib.licenses.mit;
  };
  zsh-autocomplete = mkZshPlugin rec {
    pname = "zsh-autocomplete";
    version = "23.07.13";
    src = fetchFromGitHub {
      owner = "marlonrichert";
      repo = pname;
      rev = version;
      hash = "sha256-0NW0TI//qFpUA2Hdx6NaYdQIIUpRSd0Y4NhwBbdssCs=";
    };
    meta.license = lib.licenses.mit;
  };
  zsh-edit = mkZshPlugin rec {
    pname = "zsh-edit";
    version = "unstable-2023-05-13";
    src = fetchFromGitHub {
      owner = "marlonrichert";
      repo = pname;
      rev = "9eb286982f96f03371488e910e42afb23802bdfd";
      hash = "sha256-LVHkH7fi8BQxLSeV+osdZzar1PQ0/hdb4yZ4oppGBoc=";
    };
    meta.license = lib.licenses.mit;
  };
  zsh-autopair = mkZshPlugin rec {
    pname = "zsh-autopair";
    version = "unstable-2022-10-03";
    src = fetchFromGitHub {
      owner = "hlissner";
      repo = pname;
      rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
      hash = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    };
    meta.license = lib.licenses.mit;
  };
  zsh-auto-notify = mkZshPlugin rec {
    pname = "zsh-auto-notify";
    version = "unstable-2023-06-02";
    src = fetchFromGitHub {
      owner = "MichaelAquilina";
      repo = pname;
      rev = "22b2c61ed18514b4002acc626d7f19aa7cb2e34c";
      hash = "sha256-x+6UPghRB64nxuhJcBaPQ1kPhsDx3HJv0TLJT5rjZpA=";
    };
    meta.license = lib.licenses.gpl3;
  };
  zsh-window-title = mkZshPlugin rec {
    pname = "zsh-window-title";
    version = "v1.0.2";
    src = fetchFromGitHub {
      owner = "olets";
      repo = pname;
      rev = version;
      hash = "sha256-efLpDY+cIe2KhRFpTcm85mYUFlTa2ECTIFhP7hjuf+8=";
    };
    # Actually some cobbled-together license with most parts from:
    meta.license = lib.licenses.cc-by-nc-sa-40;
  };
  zsh-fast-syntax-highlighting = mkZshPlugin rec {
    pname = "fast-syntax-highlighting";
    version = "unstable-2023-07-05";
    src = fetchFromGitHub {
      owner = "zdharma-continuum";
      repo = pname;
      rev = "cf318e06a9b7c9f2219d78f41b46fa6e06011fd9";
      hash = "sha256-RVX9ZSzjBW3LpFs2W86lKI6vtcvDWP6EPxzeTcRZua4=";
    };
    meta.license = lib.licenses.bsd3;
  };
}

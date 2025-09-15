{ lib }:
let mkParams = lib.mapAttrsToList lib.nameValuePair;
in {
  nixpkgs-unstable = {
    name = "Nixpkgs (unstable)";
    urls = [{
      template = "https://search.nixos.org/packages";
      params = mkParams {
        channel = "unstable";
        query = "{searchTerms}";
      };
    }];
    definedAliases = [ "@pkg" "@nixpkgs" ];
  };

  nixos-unstable = {
    name = "NixOS Options (unstable)";
    urls = [{
      template = "https://search.nixos.org/options";
      params = mkParams {
        channel = "unstable";
        query = "{searchTerms}";
      };
    }];
    definedAliases = [ "@opt" "@nixos" ];
  };

  home-manager-master = {
    name = "Home Manager Options (master)";
    urls = [{
      template = "https://home-manager-options.extranix.com";
      params = mkParams {
        release = "master";
        query = "{searchTerms}";
      };
    }];
    definedAliases = [ "@hm" "@home-manager" ];
  };

  lib-rs = {
    name = "Lib.rs";
    urls = [{
      template = "https://lib.rs/search";
      params = mkParams { q = "{searchTerms}"; };
    }];
    definedAliases = [ "@crate" "@librs" ];
  };
}

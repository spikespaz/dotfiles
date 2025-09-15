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
}

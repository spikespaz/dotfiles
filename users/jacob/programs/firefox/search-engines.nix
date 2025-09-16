{ lib }:
let mkParams = lib.mapAttrsToList lib.nameValuePair;
in {
  nixpkgs-unstable = {
    name = "Nixpkgs (unstable)";
    icon = "https://nixos.org/favicon.ico";
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
    icon = "https://nixos.org/favicon.ico";
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
    icon = "https://home-manager-options.extranix.com/images/favicon.ico";
    urls = [{
      template = "https://home-manager-options.extranix.com";
      params = mkParams {
        release = "master";
        query = "{searchTerms}";
      };
    }];
    definedAliases = [ "@hm" "@home-manager" ];
  };

  noogle = {
    name = "Noogle - Nixpkgs Functions";
    # The Noogle favicon is just the Nix logo, but lower quality.
    # icon = "https://noogle.dev/favicon.png";
    icon = "https://nixos.org/favicon.ico";
    urls = [{
      template = "https://noogle.dev/q";
      params = mkParams { term = "{searchTerms}"; };
    }];
    definedAliases = [ "@ngl" "@noogle" ];
  };

  lib-rs = {
    name = "Lib.rs";
    icon = "https://lib.rs/favicon.ico";
    urls = [{
      template = "https://lib.rs/search";
      params = mkParams { q = "{searchTerms}"; };
    }];
    definedAliases = [ "@crate" "@librs" ];
  };

  docs-rs = {
    name = "Docs.rs";
    icon = "https://docs.rs/-/static/favicon.ico";
    urls = [{ template = "https://docs.rs/{searchTerms}"; }];
    definedAliases = [ "@rs" "@docsrs" ];
  };
}

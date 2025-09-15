{
  nixpkgs-unstable = {
    name = "Nixpkgs (unstable)";
    urls = [{
      template = "https://search.nixos.org/packages";
      params = [
        {
          name = "channel";
          value = "unstable";
        }
        {
          name = "query";
          value = "{searchTerms}";
        }
      ];
    }];
    definedAliases = [ "@pkg" "@nixpkgs" ];
  };

  nixos-unstable = {
    name = "NixOS Options (unstable)";
    urls = [{
      template = "https://search.nixos.org/options";
      params = [
        {
          name = "channel";
          value = "unstable";
        }
        {
          name = "query";
          value = "{searchTerms}";
        }
      ];
    }];
    definedAliases = [ "@opt" "@nixos" ];
  };
}

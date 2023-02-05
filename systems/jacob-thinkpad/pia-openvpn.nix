{
  self,
  config,
  pkgs,
  lib,
  modules,
  ...
}: let
  authUserPass = config.age.secrets."root.pia.age".path;
  updateResolvConf = true;

  src = pkgs.fetchzip {
    stripRoot = false;
    url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
    sha256 = "sha256-ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
  };

  configs = removeAttrs (lib.mapAttrs' (file: type: let
    match = builtins.match "(.+)\\.ovpn" file;
    name =
      if type == "regular" && match != null
      then builtins.elemAt match 0
      else "_";
    value =
      if name != null
      then {
        inherit authUserPass updateResolvConf;
        autoStart = false;
        config = builtins.readFile "${src}/${file}";
      }
      else null;
  in {
    inherit name value;
  }) (builtins.readDir src.outPath)) ["_"];
in {
  imports = [modules.openvpn modules.age];
  age.secrets."root.pia.age".file = "${self}/secrets/root.pia.age";
  services.openvpn.alt.servers = configs;
}

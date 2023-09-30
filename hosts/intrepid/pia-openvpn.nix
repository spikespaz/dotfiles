{ self, config, pkgs, lib, ... }:
let
  authUserPass = config.age.secrets.pia-user-pass.path;
  updateResolvConf = true;

  src = pkgs.fetchzip {
    stripRoot = false;
    url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
    sha256 = "sha256-ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
  };

  configs = removeAttrs (lib.mapAttrs' (file: type:
    let
      match = builtins.match "(.+)\\.ovpn" file;
      name = if type == "regular" && match != null then
        builtins.elemAt match 0
      else
        "_";
      value = if name != null then {
        inherit authUserPass updateResolvConf;
        autoStart = false;
        config = builtins.readFile "${src}/${file}";
      } else
        null;
    in { inherit name value; }) (builtins.readDir src.outPath)) [ "_" ];
in {
  imports = [ self.nixosModules.openvpn ];
  age.secrets.pia-user-pass.file = "${self}/secrets/root.pia-user-pass.age";
  services.openvpn.alt.servers = configs;
}

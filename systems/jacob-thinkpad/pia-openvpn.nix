{
  pkgs,
  lib,
  flib,
  ...
}: let
  authUserPass = {
    username = "";
    password = "";
  };

  pia-openvpn = pkgs.fetchzip {
    stripRoot = false;
    url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
    sha256 = "sha256-ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
  };

  configs = lib.pipe (builtins.readDir "${pia-openvpn}") [
    # Step one: filter dir listing to include only *.ovpn files
    (lib.filterAttrs (fName: fType: let
      splitName = flib.rsplit "." fName;
      fExt = flib.imply splitName splitName.r;
    in
      fType == "regular" && flib.imply fExt (fExt == "ovpn")))
    # Step two:
    # - remove extension from config name
    # - read the config file to a string
    # - create new attrset with other options set, inherit config string
    (lib.mapAttrs' (fName: _: let
      name = (flib.rsplit "." fName).l;
      config = builtins.readFile "${pia-openvpn}/${fName}";
    in {
      inherit name;
      value = {
        autoStart = false;
        updateResolvConf = true;
        inherit config authUserPass;
      };
    }))
  ];
in {
  services.openvpn.servers = configs;
}

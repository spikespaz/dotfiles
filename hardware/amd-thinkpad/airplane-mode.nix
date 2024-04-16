{ self, lib, pkgs, ... }:
let
  # The hardware already gets soft-blocked, but I want a button to restart the driver if it acts up.
  # I will bind this to SHIFT + XF86WLAN.
  airplane-mode =
    (pkgs.patchShellScript "${self}/scripts/airplane-mode.sh" rec {
      name = "airplane-mode";
      destination = "/bin/${name}";
      # runtimeInputs = [ ];
      # overrideEnvironment = { };
    });
in {
  environment.systemPackages = [ airplane-mode ];

  security.sudo.extraRules = [{
    groups = [ "users" ];
    commands = [{
      command = lib.getExe airplane-mode;
      options = [ "NOPASSWD" ];
    }];
  }];
}

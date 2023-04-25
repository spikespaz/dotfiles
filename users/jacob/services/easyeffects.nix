{ lib, ... }:
let laptop-unsuck = lib.importJSON ./laptop_unsuck.json;
in {
  services.easyeffects.enable = true;

  xdg.configFile."easyeffects/output/empty.json".text = "{}";
  xdg.configFile."easyeffects/output/laptop_unsuck.json".text =
    builtins.toJSON laptop-unsuck;
  xdg.configFile."easyeffects/autoload/output/alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink:[Out] Speaker.json".text =
    builtins.toJSON {
      device = "alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink";
      device-description =
        "Family 17h/19h HD Audio Controller Speaker + Headphones";
      device-profile = "[Out] Speaker";
      preset-name = "laptop_unsuck";
    };
}

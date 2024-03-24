{ lib, pkgs, ... }:
let
  # <https://github.com/sebastian-de/easyeffects-thinkpad-unsuck>
  thinkpad-unsuck-src = pkgs.fetchFromGitHub {
    owner = "sebastian-de";
    repo = "easyeffects-thinkpad-unsuck";
    rev = "6356f4953b54911e156f31ed90da29eb4436ad7e";
    hash = "sha256-LqsiPNzU4NIhvc0+qlXIQqKEn075UK0zAoGYIcUeHrY=";
  };
  thinkpad-unsuck-json = "${thinkpad-unsuck-src}/thinkpad-unsuck.json";
in {
  services.easyeffects.enable = true;

  xdg.configFile."easyeffects/output/empty.json".text = builtins.toJSON {
    output = {
      blocklist = [ ];
      plugins_order = [ ];
    };
  };

  # All of this is really dumb.
  # There should be a default preset that is used when no other sink
  # matches an autoload configuration.
  # <https://github.com/wwmm/easyeffects/issues/1359>
  # Can I just say, EasyEffects is shitty software.

  xdg.configFile."easyeffects/output/thinkpad-unsuck.json".source =
    thinkpad-unsuck-json;

  xdg.configFile."easyeffects/autoload/output/alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink:[Out] Speaker.json".text =
    builtins.toJSON {
      device = "alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink";
      device-description =
        "Family 17h/19h HD Audio Controller Speaker + Headphones";
      device-profile = "[Out] Speaker";
      preset-name = "thinkpad-unsuck";
    };

  xdg.configFile."easyeffects/autoload/output/alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink:[Out] Headphones.json".text =
    builtins.toJSON {
      device = "alsa_output.pci-0000_08_00.6.HiFi__hw_Generic_1__sink";
      device-description =
        "Family 17h/19h HD Audio Controller Speaker + Headphones";
      device-profile = "[Out] Headphones";
      preset-name = "empty";
    };

  xdg.configFile."easyeffects/autoload/output/bluez_output.98_8E_79_00_89_6C.1:headphone-output.json".text =
    builtins.toJSON {
      device = "bluez_output.98_8E_79_00_89_6C.1";
      device-description = "Qudelix-5K";
      device-profile = "headphone-output";
      preset-name = "empty";
    };

  xdg.configFile."easyeffects/autoload/output/bluez_output.98_8E_79_00_89_6C.1:headphone-hf-output.json".text =
    builtins.toJSON {
      device = "bluez_output.98_8E_79_00_89_6C.1";
      device-description = "Qudelix-5K";
      device-profile = "headphone-hf-output";
      preset-name = "empty";
    };

  xdg.configFile."easyeffects/autoload/output/alsa_output.usb-QTIL_Qudelix-5K_USB_DAC_MIC_44.1KHz_ABCDEF0123456789-00.analog-stereo:analog-output.json".text =
    builtins.toJSON {
      device =
        "alsa_output.usb-QTIL_Qudelix-5K_USB_DAC_MIC_44.1KHz_ABCDEF0123456789-00.analog-stereo";
      device-description = "Qudelix-5K USB DAC/MIC 44.1KHz Analog Stereo";
      device-profile = "analog-output";
      preset-name = "empty";
    };
}

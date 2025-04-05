{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.hardware.keyboard.qmk;
  hardwareIdentifier = types.strMatching "[A-Fa-f0-9]{4}";
in {
  options = {
    hardware.keyboard = {
      qmk.extraDevices = lib.mkOption {
        type = types.listOf (types.submodule ({ config, ... }: {
          options = {
            name = lib.mkOption {
              type = types.nullOr types.singleLineStr;
              description =
                "The friendly name for this device (or just vendor)";
              default = null;
            };
            vendorId = lib.mkOption {
              type = hardwareIdentifier;
              description = "The vendor ID as shown from `lsusb`.";
            };
            productId = lib.mkOption {
              type = types.nullOr hardwareIdentifier;
              default = null;
              description = "The vendor ID as shown from `lsusb`.";
            };
            udevRules = lib.mkOption {
              type = types.nonEmptyStr;
              internal = true;
              readOnly = true;
            };
          };
          config = {
            udevRules = ''
              ${lib.optionalString (config.name != null) "# ${config.name}"}
              SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="${config.vendorId}", ${
                lib.optionalString (config.productId != null)
                ''ATTR{idProduct}=="${config.productId}", ''
              }MODE="0666"
              KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="${config.vendorId}", ${
                lib.optionalString (config.productId != null)
                ''ATTRS{idProduct}=="${config.productId}", ''
              }MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
            '';
          };
        }));
      };
    };
  };
  config = lib.mkIf (cfg != [ ]) {
    services.udev.packages = [
      (pkgs.writeTextDir "/lib/udev/rules.d/51-qmk-extra.rules"
        (lib.concatLines (lib.catAttrs "udevRules" cfg.extraDevices)))
    ];
  };
}

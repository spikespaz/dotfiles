{ self, ... }: {
  imports = [ self.nixosModules.disable-input-devices ];

  # create device paths to disable input devices
  programs.disable-input-devices = {
    enable = true;
    allowedGroups = [ "video" ];
    # Show all event devices:
    # $ sudo evtest
    # Get information about a device:
    # $ udevadm info -a /dev/input/eventXX
    # Test by blocking a device:
    # $ sudo evtest --grab /dev/input/eventXX
    disableDevices = {
      # "AT Translated Set 2 keyboard"
      # Laptop Keyboard
      "thinkpad/keyboard" = {
        product = "0001";
        vendor = "0001";
      };
      # "ThinkPad Extra Buttons"
      # Laptop Special Function Keys
      "thinkpad/extra-buttons" = {
        product = "5054";
        vendor = "17aa";
      };
      # "TPPS/2 Elan TrackPoint"
      # TrackPoint and Touchpad Buttons
      "thinkpad/trackpoint" = {
        product = "000a";
        vendor = "0002";
      };
      # "SynPS/2 Synaptics TouchPad"
      # Laptop Touchpad
      "thinkpad/touchpad" = {
        product = "0007";
        vendor = "0002";
      };
      # # "Power Button"
      # # Power/Sleep Button
      # "thinkpad/power-button" = {
      #   product = "0001";
      #   vendor = "0000";
      # };
      # "Lid Switch"
      # Laptop Close Switch
      "thinkpad/lid-switch" = {
        product = "0005";
        vendor = "0000";
      };
    };
  };
}

{
  hardware = {
    # update processor firmware by loading from memory at boot
    cpu.amd.updateMicrocode = true;

    # enable proprietary firmware that is still redistributable
    # required for some hardware, drivers contain proprietary blobs
    enableRedistributableFirmware = true;

    # wifi adapter
    # error: rtw89-firmware has been removed because linux-firmware now contains it.
    # firmware = [pkgs.rtw89-firmware];

    # enable bluetooth but turn off power by default
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
  };

  # firmware updater for machine hardware
  services.fwupd.enable = true;

    # enable fingerprint sensor
  services.fprintd.enable = true;

  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  # bluetooth
  services.blueman.enable = true;

  # audio and video drivers with legacy alsa, jack, and pulse support
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
}

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

    bluetooth.enable = true;
    # bluetooth.powerOnBoot = false;
  };

  # firmware updater for machine hardware
  services.fwupd.enable = true;

  # enable fingerprint sensor
  services.fprintd.enable = true;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      # Use iwd's DHCP handling for wifi interfaces.
      General.EnableNetworkConfiguration = true;
      # Default is `"systemd"`, but we want `resolved` to directly provide
      # the DNS servers from `networking.nameservers`.
      Network.NameResolvingService = "none";
    };
  };
  # Prevent conflicts with iwd's DHCP handling.
  networking.dhcpcd.denyInterfaces = [ "wl*" ];

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

{ config, pkgs, ... }:
##########################
### BOOT CONFIGURATION ###
##########################
{
  # systemd pivots to ramfs on shutdown
  # this is so that the root fs can be unmounted safely
  # it is not worth my time, I live on the edge
  systemd.shutdownRamfs.enable = false;

  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    initrd.availableKernelModules = [ "usb_storage" "rtsx_pci_sdmmc" ];

    initrd.systemd.strip = false;
    initrd.systemd.enable = true;

    loader = {
      # could be a little faster
      # TODO can this be done for plymouth?
      generationsDir.copyKernels = true;

      systemd-boot.enable = true;
      systemd-boot.editor = false;
      systemd-boot.configurationLimit = 10;

      # need to hold space to get the boot menu to appear
      timeout = 0;

      efi.efiSysMountPoint = "/boot";
      # TODO maybe?
      # efi.canTouchEfiVariables = true;
    };
  };
}

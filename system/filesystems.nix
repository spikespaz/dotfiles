# This module is responsible for configuring everything required
# to use the partition scheme defined by `partition.sh`,
# as well as making it bootable. Note that the bootloader itself
# should still be configured mostly elsewhere--at least the options
# that have the potential to vary from across systems.
#
# Further reading:
# - <https://grahamc.com/blog/erase-your-darlings>
# - <https://github.com/nix-community/impermanence>
{ ... }:
let
  zfsAuto = device: {
    inherit device;
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };
in
{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=0755" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/var/lib" = zfsAuto "ospool/var/lib";
    "/var/log" = zfsAuto "ospool/var/log";
    "/var/cache" = zfsAuto "ospool/var/cache";
    "/nix" = zfsAuto "ospool/nix";
    "/home" = zfsAuto "ospool/home";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  # Only configure the necessary prerequisite boot parameters.
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "zfs" ];

    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  # Maintenance, this should be the same across every computer
  # that uses this module.
  services.zfs = {
    trim.enable = true;
    trim.interval = "weekly";

    autoScrub.enable = true;
    autoScrub.pools = [ "ospool" ];
    autoScrub.interval = "weekly";
  };
}

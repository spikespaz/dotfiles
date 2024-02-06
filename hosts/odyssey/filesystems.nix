# This module is responsible for configuring everything required
# to use the partition scheme defined by `partition.sh`,
# as well as making it bootable. Note that the bootloader itself
# should still be configured mostly elsewhere--at least the options
# that have the potential to vary from across systems.
#
# Further reading:
# - <https://grahamc.com/blog/erase-your-darlings>
# - <https://github.com/nix-community/impermanence>
{ config, lib, pkgs, enableUnstableZfs, ... }:
let
  rootPool = "odyssey";
  bootLabel = "ODSY";

  # function to easily duplicate a zfs automount scheme
  zfsAuto = device: {
    inherit device;
    fsType = "zfs";
    options = [ "zfsutil" "X-mount.mkdir" ];
  };
in {
  # we never want to allow nix to create hard-links
  # because the filesystem takes care of that
  nix.settings.auto-optimise-store = false;

  fileSystems = {
    "/" = zfsAuto "${rootPool}/root";
    "/var/lib" = zfsAuto "${rootPool}/var/lib";
    "/var/log" = zfsAuto "${rootPool}/var/log";
    "/var/cache" = zfsAuto "${rootPool}/var/cache";
    "/nix" = zfsAuto "${rootPool}/nix";
    "/home" = zfsAuto "${rootPool}/home";

    "/boot" = {
      device = "/dev/disk/by-label/${bootLabel}";
      fsType = "vfat";
    };
  };

  swapDevices = [{ label = "swap"; }];

  # Only configure the necessary prerequisite boot parameters.
  boot = {
    # for some reason not set automatically
    # docs say this should be set auto when ""
    resumeDevice = "/dev/disk/by-label/swap";

    loader.efi.efiSysMountPoint = "/boot";

    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "zfs" ];

    kernelPackages = lib.mkForce (if enableUnstableZfs then
      (pkgs.linuxPackages_latest.extend (self: super: {
        zfsUnstable = super.zfsUnstable.overrideAttrs
          (self: super: { meta = super.meta // { broken = false; }; });
      }))
    else
      config.boot.zfs.package.latestCompatibleLinuxPackages);

    zfs = {
      enableUnstable = enableUnstableZfs;
      forceImportAll = false;
      forceImportRoot = false;
      allowHibernation = true;
    };
  };

  # Maintenance, this should be the same across every computer
  # that uses this module.
  services.zfs = {
    trim.enable = true;
    trim.interval = "weekly";

    autoScrub.enable = true;
    autoScrub.pools = [ rootPool ];
    autoScrub.interval = "weekly";
  };

  services.fstrim.enable = lib.mkForce false;
}

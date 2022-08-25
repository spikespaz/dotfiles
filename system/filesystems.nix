{ ... }:
let
  zfsAuto = device: {
      device = "${device}";
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
}

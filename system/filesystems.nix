{ config, ... }: {
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=0755" ];
    };
    "/etc/nixos" = {
      device = "ospool/etc/nixos";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/lib" = {
      device = "ospool/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/log" = {
      device = "ospool/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/cache" = {
      device = "ospool/var/cache";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/nix" = {
      device = "ospool/nix";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/home" = {
      device = "ospool/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
}

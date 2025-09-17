{ lib, config, ... }: {
  networking.hostId = builtins.substring 0 8
    (builtins.hashString "md5" config.networking.hostName);

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

  services.resolved = {
    enable = true;
    # domains = [ "~." ] ++ config.networking.search;
    fallbackDns = [ "8.8.8.8" "2001:4860:4860::8844" ];
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
    # Allegedly, Link-Local Multicast Name Resolution (port 5355) is rarely used
    # outside of Windows hosts. It can be re-enabled without fear of conflict with Avahi.
    llmnr = "false";
    extraConfig = lib.generators.toKeyValue { } {
      # Disabled for Avahi to own `.local` resolutions and discovery (port 5353).
      MulticastDNS = false;
    };
  };

  # Required for network discovery of printers.
  services.avahi = {
    enable = true;
    # Resolve `.local` domains.
    nssmdns4 = true;
    nssmdns6 = false;
  };

  # CloudFlare nameservers
  networking.nameservers =
    [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
}

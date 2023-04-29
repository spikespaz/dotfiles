{ ... }: {
  udiskie = {...}: {
    # service that auto-mounts storage devices with udisks2
    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
      # <https://github.com/coldfix/udiskie/blob/master/doc/udiskie.8.txt#configuration>
      # settings = {}
    };
  };
}

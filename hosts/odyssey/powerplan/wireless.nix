{ ... }: {
  # TLP is not enabled in this module because it has conflicts with other
  # programs that want to manage the CPU.
  services.tlp.settings = {
    # Restore the default behavior of `systemd-rfkill.service`.
    RESTORE_DEVICE_STATE_ON_STARTUP = true;

    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = [ "bluetooth" "wifi" "wwan" ];
  };
}

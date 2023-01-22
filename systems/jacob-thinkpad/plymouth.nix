{
  config,
  pkgs,
  lib,
  ...
}:
###########################
### PLYMOUTH & GRAPHICS ###
###########################
{
  # font for log text & tty
  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
    earlySetup = true;
  };

  # make the boot quiet
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  boot.kernelParams = [
    # ensures that amdgpu is loaded over radeon
    "amdgpu"
    # allows the backlight to be controlled via software
    "amdgpu.backlight=0"
    # allows systemd to set and save the backlight state
    "acpi_backlight=none"
    # prevent the kernel from blanking plymouth out of the fb
    "fbcon=nodefer"
    # disable boot logo if any
    "logo.nologo"
    # tell the kernel to not be verbose
    "quiet"
    # disable systemd status messages
    "rd.systemd.show_status=auto"
    # lower the udev log level to show only errors or worse
    "rd.udev.log_level=3"
    # disable the cursor in vt to get a black screen during intermissions
    # TODO turn back on in tty
    "vt.global_cursor_default=0"
  ];

  # configure plymouth theme
  # <https://github.com/adi1090x/plymouth-themes>
  boot.plymouth = let
    pack = 3;
    theme = "hud_3";
  in {
    enable = true;
    themePackages = [
      (pkgs.plymouth-themes.override {inherit pack theme;})
    ];
    inherit theme;
  };

  # make it work with sleep
  powerManagement.powerDownCommands = ''
    ${pkgs.plymouth} --show-splash
  '';
  powerManagement.resumeCommands = ''
    ${pkgs.plymouth} --quit
  '';
}

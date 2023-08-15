{ config, pkgs, lib, ... }:
let
  # I don't know if this is really needed, but I extrapolated this
  # package override from the nixpkgs config.
  plymouth =
    pkgs.plymouth.override { systemd = config.boot.initrd.systemd.package; };
in {
  # allow plymouth to take over the framebuffer sooner
  console.earlySetup = true;

  # make the boot quiet
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  boot.kernelParams = [
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
  # <https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/themes/adi1090x-plymouth-themes/shas.nix>
  boot.plymouth = let theme = "colorful_loop";
  in {
    enable = true;
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ theme ]; })
    ];
    inherit theme;
  };

  # make it work with sleep
  powerManagement.powerDownCommands = ''
    ${lib.getExe plymouth} --show-splash
  '';
  powerManagement.resumeCommands = ''
    ${lib.getExe plymouth} --quit
  '';
}

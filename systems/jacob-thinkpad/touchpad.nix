{pkgs, ...}: {
  # workaround for broken libinput gestures and two-finger scrolling.
  # <https://askubuntu.com/a/828920>
  # note that ${lib.getBin pkgs.kmod} does not return a path ending with /bin
  # this may need to be a bug report
  powerManagement.powerDownCommands = ''
    ${pkgs.kmod}/bin/modprobe -r psmouse
  '';
  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/modprobe psmouse
  '';
}

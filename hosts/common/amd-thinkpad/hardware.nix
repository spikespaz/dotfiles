{
  boot.initrd.kernelModules = [ "amdgpu" "nvme" ];

  boot.kernelParams = [
    # Ensure that AMDGPU is loaded over Radeon.
    "amdgpu"

    # Enable Southern Islands and Sea Islands support.
    # These flags are not mutually exclusive according to the Arch Wiki.
    # <https://wiki.archlinux.org/title/AMDGPU>
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"

    # Allow the GPU to power down when displays are attached.
    "amdgpu.runpm=-2"

    # Checked `dmesg`, it suggested that I add this.
    # Not sure if this is placebo, but I seem to notice
    # pointer acceleration being slightly smoother.
    # Anyway, it doesn't seem to hurt.
    "psmouse.synaptics_intertouch=1"
  ];

  hardware = {
    # update processor firmware by loading from memory at boot
    cpu.amd.updateMicrocode = true;
  };
}

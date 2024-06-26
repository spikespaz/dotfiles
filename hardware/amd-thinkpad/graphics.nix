{ lib, pkgs, ... }: {
  hardware.amdgpu = {
    # Ensure that AMDGPU is loaded over Radeon.
    initrd.enable = true;
    # Uses `radeon.*_support` by default, to use `amdgu.*_support`
    # change this to `true`.
    legacySupport.enable = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  environment.variables = {
    # Not sure if this should be necessary, but enabling RADV did not work.
    VK_ICD_FILENAMES = lib.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json"
      "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
    ];
    # From Mesa, for Vulkan, alongside `radeonsi` for OpenGL.
    AMD_VULKAN_ICD = "RADV";
    # Mesa Gallium driver, OpenGL to Vulkan. Third-layer abstraction.
    # MESA_LOADER_DRIVER_OVERRIDE = "zink";
    # Official AMD, directly provides OpenGL. Use RADV for Vulkan.
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };

  boot.kernelParams = [
    # Enable Southern Islands and Sea Islands support.
    # These flags are not mutually exclusive according to the Arch Wiki.
    # <https://wiki.archlinux.org/title/AMDGPU>
    # "amdgpu.si_support=1"
    # "amdgpu.cik_support=1"

    # Allow the GPU to power down when displays are attached.
    "amdgpu.runpm=-2"
  ];
}

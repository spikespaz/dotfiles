{ lib, pkgs, ... }: {
  hardware.amdgpu = {
    # Prefer `amdgpu` over `radeon`.
    legacySupport.enable = true;
    # Ensure that AMDGPU is loaded over Radeon.
    initrd.enable = true;
    # RADV is preferred for performance but `amdvlk` is fallback.
    amdvlk.enable = true;
    amdvlk.support32Bit.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.variables = {
    # Ordered.
    # <https://gitlab.com/AndrewShark/amd-vulkan-prefixes/-/blob/f5fbf9a4625db2f53137c320ce82d8394c6b7ff8/amd_vulkan_prefixes.sh#L12>
    VK_DRIVER_FILES = lib.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
      "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json"
    ];
    # From Mesa, for Vulkan, alongside `radeonsi` for OpenGL.
    # This environment variable can be changed to select `amdvlk`.
    AMD_VULKAN_ICD = "RADV";
    # Mesa Gallium driver, OpenGL to Vulkan. Third-layer abstraction.
    # MESA_LOADER_DRIVER_OVERRIDE = "zink";
    # Official AMD, directly provides OpenGL. Use RADV for Vulkan.
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };

  boot.kernelParams = [
    # Allow the GPU to power down when displays are attached.
    "amdgpu.runpm=-2"
  ];
}

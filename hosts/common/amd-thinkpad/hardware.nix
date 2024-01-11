{
  boot.kernelParams = [
    # Disable scatter/gather to prevent flickering and artifacts
    # from the iGPU under memory pressure.
    "amdgpu.sg_display=0"
  ];
}

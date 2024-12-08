# modules/intel-gpu.nix
{ config, pkgs, ... }: {
  # Enable Intel GPU kernel module
  boot.kernelModules = [ "i915" ];

  # Configure OpenGL and compute packages
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime # For OpenCL/SYCL support
      intel-ocl # Intel OpenCL ICD
    ];
  };

  # Add utilities for verification
  environment.systemPackages = with pkgs; [
    clinfo # OpenCL platform verification
  ];
}

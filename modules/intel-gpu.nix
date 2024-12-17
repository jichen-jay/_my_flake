# modules/intel-gpu.nix
{ config, pkgs, ... }: {
  # Enable Intel GPU kernel module
  boot.kernelModules = [ "i915" ];

  boot.kernelPackages = pkgs.linuxPackages;
  # Configure OpenGL and compute packages
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Compute support
      intel-compute-runtime
      intel-ocl
      mkl

      # Video acceleration
      intel-media-driver # VAAPI driver
      intel-vaapi-driver
      libva
      libva-utils
      vpl-gpu-rt # OneVPL runtime
      libvdpau-va-gl
    ];
  };

  # Video acceleration settings
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Add utilities for verification
  environment.systemPackages = with pkgs; [
    clinfo # OpenCL platform verification
    libva-utils
  ];
}

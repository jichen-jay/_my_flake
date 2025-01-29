{
  config,
  pkgs,
  lib,
  inputs,
  isDesktop,
  ...
}:

let
  devPackages = with pkgs; [
    cmake
    ninja
    gnumake
    gcc
    binutils
    grpcurl
    podman
    eza
  ];

  desktopPackages = with pkgs; [
    xclip
    gnome-keyring
  ];

in
{

  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "24.11";
  };

  home.packages =
    with pkgs;
    [
      libsecret
    ]
    ++ devPackages
    ++ (lib.optionals isDesktop desktopPackages);

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      userName = "jaykchen@icloud.com";
      userEmail = "jaykchen@icloud.com";
    };

  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

}

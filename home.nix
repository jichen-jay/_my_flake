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
  ];

  utilityPackages = with pkgs; [
    eza
  ];

  desktopPackages = with pkgs; [
    google-chrome
    telegram-desktop
    font-manager
    xfce.xfce4-screenshooter
    xfce.xfce4-clipman-plugin
    zoom-us
    xclip
    gnome-keyring
    jetbrains-mono
    xdg-utils
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
    ++ utilityPackages
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

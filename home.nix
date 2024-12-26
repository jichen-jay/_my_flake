{
  config,
  pkgs,
  lib,
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
    ripgrep
    fzf
    tmux
    bat
    eza
    jq
    wget
    tree
    curl
    file
    xclip
    btop
    tokei
  ];

  desktopPackages = with pkgs; [
    google-chrome
    telegram-desktop
    font-manager
    xfce.xfce4-screenshooter
    xfce.xfce4-clipman-plugin
    zoom-us
  ];

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
  };

  home.username = "jaykchen";
  home.homeDirectory = "/home/jaykchen";
  home.stateVersion = "24.11";

  home.packages =
    with pkgs;
    [
      nil
      git
      nixpkgs-fmt
      libsecret
      gnome-keyring
      jetbrains-mono
      xdg-utils
    ]
    ++ devPackages
    ++ utilityPackages
    ++ desktopPackages;

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        ci = "git commit";
        co = "git checkout";
        st = "git status";
        lg = "git log";
        gs = "git log -S";
      };
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

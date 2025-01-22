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
      nil
      git
      nixpkgs-fmt
      libsecret
    ]
    ++ devPackages
    ++ utilityPackages
    ++ (lib.optionals isDesktop desktopPackages);

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
        dls = "sudo docker image ls";
        dps = "sudo docker ps -a";
        dcm = "sudo docker commit";
        dri = "sudo docker run --rm -it";
        dpl = "sudo docker pull";
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

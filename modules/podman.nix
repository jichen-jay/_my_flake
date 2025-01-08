{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    podman = {
      enable = true;
      # Set dockerCompat to false if using Docker
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      docker
      podman
      podman-tui
      podman-compose
      devcontainer
      buildah
      skopeo
      dive
      crun
      conmon
      fuse-overlayfs
      slirp4netns
      netavark
      aardvark-dns
      coreutils
      util-linux
      lunarvim
    ];
    sessionVariables.XDG_RUNTIME_DIR = "/run/user/1001";
  };

  systemd.tmpfiles.rules = [
    "d /run/containers 0755 root root"
    "d /etc/containers 0755 root root"
    "d %t/jaykchen 0700 jaykchen users"
    "d %t/jaykchen/containers 0700 jaykchen users"
  ];

  security.pam.loginLimits = [
    {
      domain = "jaykchen";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "jaykchen";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  services.logind = {
    lidSwitch = "suspend";
    extraConfig = ''
      RuntimeDirectorySize=10%
      HandlePowerKey=suspend
    '';
  };

  home-manager = {
    backupFileExtension = "bkp";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jaykchen = {
      programs.bash.enable = true;
      home.stateVersion = "24.11";
    };
  };
}

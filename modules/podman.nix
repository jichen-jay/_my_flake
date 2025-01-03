{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    # Setting up containers.conf
    containers = {
      enable = true;
      containersConf.settings.engine = {
        # netavark needs to be in the path, podman is not
        helper_binaries_dir = [ "${pkgs.netavark}/bin" ];
        network_backend = "netavark";
        runtime = "crun";
        runtime_path = [ "${pkgs.runc}/bin/runc" ];
        database_path = "/home/jaykchen/.local/share/containers/storage/podman-containers.conf";
      };
      storage.settings.storage = {
        driver = "overlay";
        runroot = "/run/user/1001/containers";
        graphroot = "/home/jaykchen/.local/share/containers/storage";
        options.mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      podman
      podman-tui
      podman-compose
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

  # Move as much as possible to containers.conf
  systemd.tmpfiles.rules = [
    "d /run/containers 0755 root root"
    "d /etc/containers 0755 root root"
    "d /run/user/1001 0700 jaykchen users - - - -"
    "d /run/user/1001/containers 0700 jaykchen users - - - -"
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

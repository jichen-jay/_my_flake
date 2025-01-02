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
    containers = {
      enable = true;
      containersConf.settings.engine = {
        helper_binaries_dir = [
          "${pkgs.netavark}/bin"
          "${pkgs.podman}/libexec/podman"
        ];
        network_backend = "netavark";
        runtime = "crun";
        runtime_path = [ "${pkgs.runc}/bin/runc" ];
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
    ];
    sessionVariables.XDG_RUNTIME_DIR = "/run/user/1001";
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  '';

  environment.etc."containers/policy.json" = {
    mode = "0644";
    text = lib.mkForce ''
      {
          "default": [{"type": "insecureAcceptAnything"}],
          "transports": {
              "docker": {
                  "": [{"type": "insecureAcceptAnything"}]
              }
          }
      }
    '';
  };

  system.activationScripts = {
    podman-permissions = {
      deps = [ "users" ];
      text = ''
        mkdir -p /run/libpod
        chown -R jaykchen:users /run/libpod
        chmod 0755 /run/libpod
        touch /run/libpod/alive.lck
        chown jaykchen:users /run/libpod/alive.lck
        chmod 0644 /run/libpod/alive.lck
      '';
    };

    podman-setup = {
      deps = [
        "users"
        "groups"
      ];
      text = ''
        umask 0002
        mkdir -p -m 0700 /home/jaykchen/.local/share/containers/storage/{libpod,overlay,volumes}
        chown -R jaykchen:users /home/jaykchen/.local/share/containers
        chmod -R 0700 /home/jaykchen/.local/share/containers
        mkdir -p -m 0700 /run/user/1001/{containers,libpod/tmp}
        chown -R jaykchen:users /run/user/1001/{containers,libpod}
        ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
        mkdir -p -m 0700 /etc/containers/storage.conf.d
        mkdir -p -m 0700 /home/jaykchen/.config/containers
        touch /home/jaykchen/.config/containers/containers.conf
        chown -R jaykchen:users /home/jaykchen/.config/containers
        chmod -R 0700 /home/jaykchen/.config/containers
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/containers 0755 root root"
    "d /etc/containers 0755 root root"
    "d /run/user/1001 0700 jaykchen users - - - -"
    "d /run/user/1001/containers 0700 jaykchen users - - - -"
    "d /run/user/1001/libpod 0700 jaykchen users - - - -"
    "d /run/user/1001/libpod/tmp 0700 jaykchen users - - - -"
    "d /run/libpod 0755 jaykchen users"
    "f /run/libpod/alive.lck 0644 jaykchen users"
    "d /run/libpod/tmp 0700 jaykchen users"
    "Z /run/libpod - jaykchen users"
    ''d "${config.users.users.jaykchen.home}/.config" 0770 jaykchen jaykchen - -''
    ''d "${config.users.users.jaykchen.home}/.config/home-manager" 0770 jaykchen jaykchen - -''
    ''d "${config.users.users.jaykchen.home}/.local/state" 0755 jaykchen users - -''
    ''d "${config.users.users.jaykchen.home}/.local/state/home-manager" 0755 jaykchen users - -''
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
  };

  home-manager.users.jaykchen =
    { pkgs, ... }:
    {
      home.activation = {
        createDirs = {
          before = [ "checkLinkTargets" ];
          after = [ ];
          data = ''
            mkdir -p $HOME/.local/state/home-manager
          '';
        };
        removeConflicts = {
          before = [ "checkLinkTargets" ];
          after = [ ];
          data = ''
            rm -f $HOME/.config/home-manager/*.bkp
          '';
        };
      };

      programs.bash.enable = true;
      services.podman = {
        enable = true;
        autoUpdate.enable = true;
      };
      home.stateVersion = "24.11";
    };
}

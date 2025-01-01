{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "jaykchen";
  uid = "1000";
in
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
        runroot = "/run/user/${uid}/containers";
        graphroot = "/home/${user}/.local/share/containers/storage";
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
    sessionVariables.XDG_RUNTIME_DIR = "/run/user/${uid}";
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  '';

  environment.etc = {
    "containers/policy.json" = {
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
  };

  system.activationScripts = {
    podman-permissions = {
      deps = [ "users" ];
      text = ''
        mkdir -p /run/libpod
        chown -R ${user}:users /run/libpod
        chmod 0755 /run/libpod
        touch /run/libpod/alive.lck
        chown ${user}:users /run/libpod/alive.lck
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

        # Create and set permissions for container storage
        mkdir -p -m 0700 /home/${user}/.local/share/containers/storage/{libpod,overlay,volumes}
        chown -R ${user}:users /home/${user}/.local/share/containers
        chmod -R 0700 /home/${user}/.local/share/containers

        # Create and set permissions for runtime directories
        mkdir -p -m 0700 /run/user/${uid}/{containers,libpod/tmp}
        chown -R ${user}:users /run/user/${uid}/{containers,libpod}

        # Create podman network if it doesn't exist
        ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman

        # Setup container configuration directories
        mkdir -p -m 0700 /etc/containers/storage.conf.d
        mkdir -p -m 0700 /home/${user}/.config/containers
        touch /home/${user}/.config/containers/containers.conf
        chown -R ${user}:users /home/${user}/.config/containers
        chmod -R 0700 /home/${user}/.config/containers
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/containers 0755 root root"
    "d /etc/containers 0755 root root"
    "d /run/user/${uid} 0700 ${user} users - - - -"
    "d /run/user/${uid}/containers 0700 ${user} users - - - -"
    "d /run/user/${uid}/libpod 0700 ${user} users - - - -"
    "d /run/user/${uid}/libpod/tmp 0700 ${user} users - - - -"
    "d /run/libpod 0755 ${user} users"
    "f /run/libpod/alive.lck 0644 ${user} users"
    "d /run/libpod/tmp 0700 ${user} users"
    "Z /run/libpod - ${user} users"
  ];

  security.pam.loginLimits = [
    {
      domain = "${user}";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "${user}";
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
}

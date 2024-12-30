{ config, pkgs, ... }:

let
  user = "jaykchen";
  uid = "1000";
in
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
    extraPackages = with pkgs; [
      netavark
      aardvark-dns
      runc
      dive
      podman-compose
      podman-tui
      buildah
      skopeo
      fuse-overlayfs
      util-linux
      crun
      conmon
    ];
  };

  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      engine = {
        helper_binaries_dir = [ "${pkgs.netavark}/bin" ];
        runtime_path = [ "${pkgs.runc}/bin/runc" ];
      };
    };
    registries = {
      search = [ "docker.io" ];
    };
    storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/user/${uid}/containers";
        graphroot = "/home/${user}/.local/share/containers/storage";
        options = {
          mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
        };
      };
    };
  };

  users.users.${user} = {
    extraGroups = [
      "podman"
      "wheel"
    ];
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  systemd = {
    user = {
      services.enable-linger = {
        description = "Enable lingering for user";
        wantedBy = [ "default.target" ];
        script = ''
          ${pkgs.systemd}/bin/loginctl enable-linger ${user}
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
    tmpfiles.rules = [
      "d /run/user/${uid} 0700 ${user} users"
      "d /run/user/${uid}/containers 0700 ${user} users"
      "d /run/user/${uid}/libpod 0700 ${user} users"
      "d /run/user/${uid}/libpod/tmp 0700 ${user} users"
      "d /run/libpod 0700 ${user} users"
    ];
  };

  services.logind = {
    lidSwitch = "suspend";
    extraConfig = ''
      RuntimeDirectorySize=8G
      HandlePowerKey=suspend
    '';
  };

  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/run/user/${uid}";
  };

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

  system.activationScripts = {
    podman-setup = {
      deps = [
        "users"
        "groups"
      ];
      text = ''
        # Ensure XDG directories exist
        mkdir -p /home/${user}/.local/share
        mkdir -p /home/${user}/.config

        # Create podman directories with correct permissions
        mkdir -p /home/${user}/.local/share/containers/storage/libpod
        mkdir -p /home/${user}/.local/share/containers/storage/overlay
        mkdir -p /home/${user}/.local/share/containers/storage/overlay-containers
        mkdir -p /home/${user}/.local/share/containers/storage/overlay-images
        mkdir -p /home/${user}/.local/share/containers/storage/overlay-layers
        mkdir -p /home/${user}/.config/containers/storage.conf.d

        # Set correct ownership
        chown -R ${user}:users /home/${user}/.local/share/containers
        chown -R ${user}:users /home/${user}/.config/containers

        # Set restrictive permissions
        chmod -R 700 /home/${user}/.local/share/containers
        chmod -R 700 /home/${user}/.config/containers

        # Create runtime directories
        mkdir -p /run/user/${uid}/containers
        mkdir -p /run/user/${uid}/libpod/tmp
        chown -R ${user}:users /run/user/${uid}
        chmod -R 700 /run/user/${uid}

        # Write storage configuration
        cat > /home/${user}/.config/containers/storage.conf << EOF
        [storage]
        driver = "overlay"
        graphroot = "/home/${user}/.local/share/containers/storage"
        runroot = "/run/user/${uid}/containers"

        [storage.options]
        mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"

        [storage.options.overlay]
        mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
        mountopt = "nodev,metacopy=on"
        EOF

        # Reset any existing podman state
        if [ -d "/home/${user}/.local/share/containers/storage" ]; then
          rm -rf /home/${user}/.local/share/containers/storage/*
        fi

        # Create default network if it doesn't exist
        ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
      '';
    };
  };
}

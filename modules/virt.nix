{ config, pkgs, ... }:

let
  user = "jaykchen";
  uid = toString config.users.users.${user}.uid;
  gid = toString config.users.groups.users.gid;
  containerDir = "/run/${user}/1000/containers";
in
{
  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      engine = {
        helper_binaries_dir = [ "${pkgs.netavark}/bin" ];
        runtime_path = [ "${pkgs.runc}/bin/runc" ];
      };
    };
    policy = {
      default = [
        {
          type = "insecureAcceptAnything";
        }
      ];
    };
    registries = {
      search = [ "docker.io" ];
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
    extraPackages = with pkgs; [
      netavark
      fuse-overlayfs
      aardvark-dns
      runc
      # Add container tools here instead of systemPackages
      dive
      podman-compose
      podman-tui
      buildah
      skopeo
    ];
  };

  # Remove duplicate user configuration since it's in users.nix
  # users.users.${user} = { ... };

  systemd = {
    mounts = [
      {
        what = "tmpfs";
        where = containerDir;
        type = "tmpfs";
        wantedBy = [ "multi-user.target" ];
        options = "rw,size=1G,mode=700,uid=${uid},gid=${gid}";
      }
    ];

    tmpfiles.rules = [
      "d ${containerDir} 0700 ${user} users -"
    ];
  };

  system.activationScripts = {
    podman-dirs = {
      deps = [ ];
      text = ''
        # System directories
        mkdir -p /var/lib/containers

        # User runtime directories
        mkdir -p ${containerDir}
        mkdir -p /run/${user}/1000

        # Set ownership and permissions
        chown ${user}:users /run/${user}
        chown ${user}:users /run/${user}/1000
        chown -R ${user}:users ${containerDir}
        chmod 700 /run/${user}
        chmod 700 /run/${user}/1000
        chmod 700 ${containerDir}

        # User data directories
        mkdir -p /home/${user}/.local/share/containers
        mkdir -p /home/${user}/.config/containers
        chown -R ${user}:users /home/${user}/.local/share/containers
        chown -R ${user}:users /home/${user}/.config/containers
        chmod 700 /home/${user}/.local/share/containers
        chmod 700 /home/${user}/.config/containers
      '';
    };

    podman-storage-conf = {
      deps = [ "podman-dirs" ];
      text = ''
                cat > /home/${user}/.config/containers/storage.conf << EOF
        [storage]
        driver = "overlay"
        graphroot = "/home/${user}/.local/share/containers/storage"
        runroot = "${containerDir}"
        EOF
      '';
    };

    podman-network = {
      deps = [ "podman-storage-conf" ];
      text = ''
        ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
      '';
    };
  };
}

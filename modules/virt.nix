{ config, pkgs, ... }:

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
      default = [ { type = "insecureAcceptAnything"; } ];
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
    extraPackages = [
      pkgs.netavark
      pkgs.fuse-overlayfs
      pkgs.aardvark-dns
      pkgs.runc
    ];
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-compose
    podman-tui
    buildah
    skopeo
  ];

  users.users.jaykchen = {
    extraGroups = [ "podman" ];
    group = "users"; # Add this line to specify primary group
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

  fileSystems."/run/jaykchen/1000/containers" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "rw"
      "size=1G"
      "mode=700"
      "uid=${toString config.users.users.jaykchen.uid}"
      "gid=${toString config.users.groups.users.gid}" # Changed to use system users group GID
    ];
  };

  system.activationScripts = {
    podman-network = ''
      ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
    '';
    podman-config = ''
            mkdir -p /etc/containers
            mkdir -p /var/lib/containers
            mkdir -p /run/jaykchen/1000/containers
            mkdir -p /run/jaykchen/1000

            # Set proper ownership for container directories
            chown jaykchen:users /run/jaykchen
            chown jaykchen:users /run/jaykchen/1000
            chown -R jaykchen:users /run/jaykchen/1000/containers
            chmod 700 /run/jaykchen
            chmod 700 /run/jaykchen/1000
            chmod 700 /run/jaykchen/1000/containers

            # Ensure policy.json exists and has proper content
            cat > /etc/containers/policy.json << EOF
      {
          "default": [
              {
                  "type": "insecureAcceptAnything"
              }
          ]
      }
      EOF
            chown -R jaykchen:users /home/jaykchen/.local/share/containers 2>/dev/null || true
            chmod 700 /home/jaykchen/.local/share/containers 2>/dev/null || true
    '';
    podman-storage-conf = ''
            mkdir -p /home/jaykchen/.config/containers
            cat > /home/jaykchen/.config/containers/storage.conf << EOF
      [storage]
      driver = "overlay"
      graphroot = "/home/jaykchen/.local/share/containers/storage"
      runroot = "/run/jaykchen/1000/containers"
      EOF
            chown -R jaykchen:users /home/jaykchen/.config/containers
            chmod 700 /home/jaykchen/.config/containers
    '';
  };
}

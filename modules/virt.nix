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

  # environment.persistence."/persist" = {
  #   users.jaykchen.directories = [
  #     ".local/share/containers"
  #   ];
  # };

  users.users.jaykchen = {
    extraGroups = [ "podman" ];
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
      "mode=1777"
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
    '';
    podman-storage-conf = ''
            mkdir -p /home/jaykchen/.config/containers
            cat > /home/jaykchen/.config/containers/storage.conf << EOF
      [storage]
      driver = "overlay"
      graphroot = "/home/jaykchen/.local/share/containers/storage"
      runroot = "/run/jaykchen/1000/containers"
      EOF
    '';
  };
}

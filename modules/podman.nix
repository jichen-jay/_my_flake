{ config, pkgs, ... }:

let
  user = "jaykchen";
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
  };

  system.activationScripts = {
    podman-setup = {
      deps = [
        "users"
        "groups"
      ];
      text = ''
        mkdir -p /var/lib/containers
        mkdir -p /home/${user}/.local/share/containers
        mkdir -p /home/${user}/.config/containers
        chown -R ${user}:users /home/${user}/.local/share/containers
        chown -R ${user}:users /home/${user}/.config/containers
        chmod 700 /home/${user}/.local/share/containers
        chmod 700 /home/${user}/.config/containers

        cat > /home/${user}/.config/containers/storage.conf << EOF
        [storage]
        driver = "overlay"
        graphroot = "/home/${user}/.local/share/containers/storage"
        runroot = "/run/user/1000/containers"
        EOF

        ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
      '';
    };
  };
}

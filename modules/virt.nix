{ config, pkgs, ... }:

{
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-compose
    podman-tui
  ];

  # environment.persistence."/persist" = {
  #   users.jaykchen.directories = [
  #     ".local/share/containers"
  #   ];
  # };

  # Enable Docker socket compatibility
  virtualisation.podman.dockerSocket.enable = true;

  users.users.jaykchen = {
    extraGroups = [ "podman" ];
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
  # Create Podman network on system activation
  system.activationScripts.podman-network = ''
    ${pkgs.podman}/bin/podman network exists podman || ${pkgs.podman}/bin/podman network create podman
  '';
}

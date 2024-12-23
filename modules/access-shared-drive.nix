{ config, pkgs, ... }:
{
  services.rpcbind.enable = true; # Enable NFS client support

  fileSystems."/mnt/nfs-public" = {
    device = "10.0.0.129:/var/nfs/public";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noauto"
      "x-systemd.automount"
      "rw"
      "soft"
      "timeo=30"
      "rsize=32768"
      "wsize=32768"
    ];
  };
}

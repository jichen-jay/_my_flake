{
  config,
  lib,
  pkgs,
  ...
}:

{
  # NixOS user configuration
  users.users.jaykchen = {
    isNormalUser = true;
    description = "jaykchen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman" # Keep this for podman access
      "docker" # For docker compatibility
      "storage"
    ];
    createHome = true;
    home = "/home/jaykchen";
    group = "users";
    shell = pkgs.zsh;

    # Keep these for container user namespacing
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

  programs.zsh.enable = true;

}

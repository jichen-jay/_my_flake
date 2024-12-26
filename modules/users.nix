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
    shell = pkgs.bash;
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

  # Home Manager configuration
  home-manager.users.jaykchen =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          # Add your regular user packages here
        ];
        stateVersion = "24.11";
      };

      programs = {
        zsh = {
          enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
          };
          plugins = [
            {
              name = "zsh-autosuggestions";
              src = pkgs.zsh-autosuggestions;
            }
          ];
          initExtra = ''
            # Your custom Zsh config here
          '';
        };
      };

    };

  # Display manager configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "jaykchen";
  };
}

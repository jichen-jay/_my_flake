{ config, lib, pkgs, ... }:

{
  # NixOS user configuration
  users.users.jaykchen = {
    isNormalUser = true;
    description = "jaykchen";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Home Manager configuration
  home-manager.users.jaykchen = { pkgs, ... }: {
    home = {
      packages = with pkgs; [
        # ... other packages ...
      ];
      stateVersion = "24.11"; # Add this required field
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

    home.file = {
      ".bashrc".text = ''
        # Your bashrc contents if you need them (even if Zsh is primary)
      '';
    };
  };

  # Display manager configuration should be in the NixOS configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "jaykchen";
  };
}

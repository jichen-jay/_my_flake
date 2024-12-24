{ config, pkgs, ... }:
{
  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      22
      8000
      8080
    ];
  };

  # Tmux Configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse off
    '';
    plugins = with pkgs.tmuxPlugins; [
      yank
      resurrect
      continuum
    ];
  };
}

{ config, pkgs, ... }: {
  # Networking
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [ 22 8000 8080 ]; # SSH, etc.

  # X11 and Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  
  # Keyboard Layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Audio (Pipewire)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Gnome Keyring (for secrets)
  services.gnome.gnome-keyring.enable = true;

  # VSCode Server
  services.vscode-server.enable = true;

  # OpenSSH Server
  services.openssh.enable = true;
  services.openssh.authorizedKeysFiles = [ "/home/jaykchen/.ssh/authorized_keys" ];

  # Programs
  programs.firefox.enable = true;

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

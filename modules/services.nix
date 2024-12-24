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

  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Thunar configuration
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Add Xfce plugins to system packages
  environment.systemPackages = with pkgs.xfce; [
    xfce4-clipman-plugin
  ];

  # Printing
  services.printing.enable = true;

  # Audio (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Gnome Keyring
  services.dbus.packages = [ pkgs.gnome.seahorse ];
  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
  };
  
  services.gnome = {
    gnome-keyring.enable = true;
    core-utilities.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };

  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };

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

  # User account
  users.users.jaykchen = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.bash;
  };

  # Nix settings
  nix = {
    package = pkgs.nixVersions.stable;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # System state version
  system.stateVersion = "24.11";
}

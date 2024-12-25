{ config, pkgs, ... }:

{
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

  services.ratbagd.enable = true;
  users.users.jaykchen.extraGroups = [ "input" ];
  
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

  # Programs
  programs.firefox.enable = true;

}

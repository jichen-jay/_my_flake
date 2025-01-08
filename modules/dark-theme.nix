{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    xfce.xfce4-genmon-plugin
    gnome-settings-daemon
    gsettings-desktop-schemas
    xfce.xfconf
    xfce.xfce4-settings
    glib
  ];

  # Enable required services
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };
}

{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    xfce.xfce4-genmon-plugin
    gsettings-desktop-schemas
    gnome.gnome-settings-daemon
    xfconf
  ];

  # Enable required services
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };

  # Ensure xfconf is available
  programs.dconf.enable = true;
}

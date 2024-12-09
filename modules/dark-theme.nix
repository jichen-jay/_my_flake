{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    xfce.xfce4-genmon-plugin
    gnome-settings-daemon
    gsettings-desktop-schemas
    xfce.xfconf
  ];

  # Enable required services
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };

  # Ensure xfconf is available
  programs.xfconf.enable = true;
  # programs.dconf.enable = true;
}

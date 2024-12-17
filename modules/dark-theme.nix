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

  # Enable dconf (needed for gsettings)
  programs = {
    xfconf.enable = true;
    dconf.enable = true; # Add this
  };

  # not needed in pure Nixos
  # environment.sessionVariables = {
  #   XDG_DATA_DIRS = [
  #     "${config.system.path}/share"
  #     "$HOME/.nix-profile/share"
  #     "$HOME/.share" # Add this
  #   ];
  # };
}

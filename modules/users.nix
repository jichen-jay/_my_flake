{ config, pkgs, ... }: {
  # User Account
  users.users.jaykchen = {
    isNormalUser = true;
    description = "jaykchen";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Auto-login
services.xserver.displayManager.autoLogin.enable = true;
services.xserver.displayManager.autoLogin.user = "jaykchen";

# services.xserver.displayManager.lightdm.enable = true;
# services.xserver.desktopManager.xfce.enable = true;


  # User Packages (if any)
  users.users.jaykchen.packages = with pkgs; [
    # User-specific packages can be listed here
  ];
}

{ config, pkgs, ... }: {
  # User Account
  users.users.jaykchen = {
    isNormalUser = true;
    description = "jaykchen";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Auto-login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jaykchen";

  # User Packages (if any)
  users.users.jaykchen.packages = with pkgs; [
    # User-specific packages can be listed here
  ];
}

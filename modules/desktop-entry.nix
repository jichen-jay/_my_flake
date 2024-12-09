{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (makeDesktopItem {
      name = "theme-toggle";
      desktopName = "Theme Toggle";
      comment = "Switch between light and dark themes";
      exec = "bash -c /home/jaykchen/.local/bin/xfce4-night-mode.sh toggle";
      icon = "org.xfce.settings.display"; # Use icon name without full path
      terminal = false;
      categories = [ "Settings" "DesktopSettings" "X-XFCE" "Utility" ];
      startupNotify = false;
    })
  ];
}

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # (makeDesktopItem {
    #   name = "theme-toggle";
    #   desktopName = "Theme Toggle";
    #   comment = "Switch between light and dark themes";
    #   exec = "bash -c \"export PATH=/run/current-system/sw/bin:\\$PATH && /home/jaykchen/.local/bin/xfce4-night-mode.sh toggle\"";
    #   terminal = false;
    #   categories = [
    #     "Settings"
    #     "DesktopSettings"
    #     "X-XFCE"
    #     "Utility"
    #   ];
    #   startupNotify = false;
    # })

    (makeDesktopItem {
      name = "chatbox";
      desktopName = "Chatbox";
      comment = "Chatbox Application";
      exec = "bash -c \"export PATH=/run/current-system/sw/bin:\\$PATH && appimage-run /home/jaykchen/Chatbox-1.9.7-x86_64.AppImage\"";
      icon = "org.xfce.settings.display"; # Use icon name without full path
      terminal = false;
      categories = [
        "Network"
        "Chat"
        "InstantMessaging"
        "Utility"
      ];
      startupNotify = false;
    })

  ];
}

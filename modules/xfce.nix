{ config, pkgs, ... }:

{
  # Add theme-related packages
  environment.systemPackages = with pkgs; [
    xfce.xfce4-clipman-plugin
    gsettings-desktop-schemas
    gnome-themes-extra
    dconf-editor # Add this for better dconf management
    xfce.xfconf # Add this for xfce settings management



    # Modify theme-switch script to include p10k integration
    (writeScriptBin "theme-switch" ''
      #!${pkgs.bash}/bin/bash
      mkdir -p ~/.local/share/xfce4/terminal/colorschemes

      case "$1" in
        "dark")
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
          xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
          ;;
        "light")
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
          xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita"
          ;;
        *)
          ;;
      esac
    '')
  ];

  programs = {
    dconf.enable = true;
    xfconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    firefox.enable = true;
  };

  # Configure XFCE specific settings
  services.xserver.desktopManager.xfce = {
    enable = true;
    noDesktop = false;
    enableXfwm = true;
     enableScreensaver = false;
  };

  # Display manager configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "jaykchen";
  };

  services.ratbagd.enable = true;

  home-manager.users.jaykchen = {
    home.stateVersion = "24.11";
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark";
        color-scheme = "prefer-dark";
      };
    };

    xdg.configFile = {
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".source = ./xfce-xml/xfce4-panel.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".source = ./xfce-xml/xfce4-desktop.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml".source =
        ./xfce-xml/xfce4-power-manager.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-notifyd.xml".source = ./xfce-xml/xfce4-notifyd.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml".source = ./xfce-xml/xfce4-terminal.xml;

      "xfce4/terminal/terminalrc".text = ''
        [Configuration]
        ColorForeground=#dcdcdc
        ColorBackground=#2c2c2c
        ColorCursor=#dcdcdc
        ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#729fcf;#ad7fa8;#34e2e2;#eeeeec
        ColorScheme=dark
        ThemeDark=true
      '';

      # Add any additional XFCE packages needed for your configuration
      environment.systemPackages = with pkgs; [
        xfce.xfce4-panel
        xfce.xfce4-power-manager
        xfce.xfce4-notifyd
      ];
    };

  };

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
  services.dbus.packages = [ pkgs.seahorse ];
  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
  };

  services.gnome = {
    gnome-keyring.enable = true;
    # core-utilities.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };

}

{
  config,
  pkgs,
  inputs,
  ...
}:

{

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://neovim-nightly.cachix.org" # Keeping your existing cachix
    ];
    trusted-public-keys = [
      "neovim-nightly.cachix.org-1:feIoInHRevVEplgdZvQDjhp11kYASYCE2NGY9hNrwxY="
    ];
    auto-optimise-store = true;
  };
  # Add theme-related packages
  environment.systemPackages = with pkgs; [
    xfce.xfce4-clipman-plugin
    gnome-themes-extra
    gnome-settings-daemon
    dconf-editor
    xfce.xfconf
    xfce.xfce4-panel
    xfce.xfce4-power-manager
    xfce.xfce4-notifyd
    xfce.xfce4-genmon-plugin
    xfce.xfce4-screenshooter
    xfce.xfce4-settings
    telegram-desktop
    font-manager
    zoom-us
    jetbrains-mono
    xdg-utils
    gsettings-desktop-schemas
    glib
    google-chrome
    appimage-run
    chromium
    nyxt
    (writeScriptBin "theme-switch" ''
      #!${pkgs.zsh}/bin/zsh
      case "$1" in
        "dark")
          xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
          xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
          ;;
        "light")
          xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita"
          xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus"
          gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
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

  services = {
    gvfs.enable = true;
  };

  services.displayManager = {
    defaultSession = "xfce";
    autoLogin = {
      enable = true;
      user = "jaykchen";
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xfce = {
      enable = true;
      noDesktop = false;
      enableXfwm = true;
      enableScreensaver = false;
    };
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
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source =
        ./xfce-xml/xfce4-keyboard-shortcuts.xml;

      # Clipman autostart
      "autostart/xfce4-clipman-plugin-autostart.desktop".text = ''
        [Desktop Entry]
        Hidden=false
        TryExec=xfce4-clipman
        Exec=xfce4-clipman
      '';

      # Screenshooter settings
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-screenshooter.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <channel name="xfce4-screenshooter" version="1.0">
          <property name="actions" type="empty">
            <property name="show_in_folder" type="bool" value="false"/>
            <property name="show_mouse" type="bool" value="true"/>
            <property name="take_window_shot" type="bool" value="false"/>
          </property>
          <property name="app" type="empty">
            <property name="last_user" type="string" value=""/>
          </property>
          <property name="default" type="empty">
            <property name="delay" type="int" value="0"/>
            <property name="region" type="int" value="3"/>
            <property name="action" type="int" value="1"/>
            <property name="show_mouse" type="bool" value="true"/>
            <property name="title" type="bool" value="true"/>
          </property>
        </channel>
      '';

      # Power manager settings
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <channel name="xfce4-power-manager" version="1.0">
          <property name="xfce4-power-manager" type="empty">
            <property name="show-tray-icon" type="bool" value="false"/>
            <property name="power-button-action" type="uint" value="4"/>
            <property name="lock-screen-suspend-hibernate" type="bool" value="false"/>
            <property name="dpms-on-ac-off" type="uint" value="32"/>
            <property name="dpms-on-ac-sleep" type="uint" value="31"/>
            <property name="blank-on-ac" type="int" value="17"/>
            <property name="sleep-button-action" type="uint" value="3"/>
            <property name="hibernate-button-action" type="uint" value="3"/>
            <property name="battery-button-action" type="uint" value="3"/>
          </property>
        </channel>
      '';

      # Session settings
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <channel name="xfce4-session" version="1.0">
          <property name="general" type="empty">
            <property name="PromptOnLogout" type="bool" value="false"/>
          </property>
          <property name="shutdown" type="empty">
            <property name="LockScreen" type="bool" value="false"/>
          </property>
          <property name="chooser" type="empty">
            <property name="AlwaysDisplay" type="bool" value="false"/>
          </property>
        </channel>
      '';

      # Pointer settings
      "xfce4/xfconf/xfce-perchannel-xml/pointers.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <channel name="pointers" version="1.0">
          <property name="Logitech_G604_" type="empty">
            <property name="RightHanded" type="bool" value="true"/>
            <property name="ReverseScrolling" type="bool" value="true"/>
            <property name="Threshold" type="int" value="1"/>
            <property name="Acceleration" type="double" value="5.0"/>
          </property>
        </channel>
      '';

      # Clipman settings
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-clipman.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <channel name="xfce4-clipman" version="1.0">
          <property name="settings" type="empty">
            <property name="add-primary-clipboard" type="bool" value="true"/>
          </property>
        </channel>
      '';

      # Terminal settings
      "xfce4/terminal/terminalrc".text = ''
        [Configuration]
        ColorForeground=#dcdcdc
        ColorBackground=#2c2c2c
        ColorCursor=#dcdcdc
        ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#729fcf;#ad7fa8;#34e2e2;#eeeeec
        ColorScheme=dark
        ThemeDark=true
      '';
    };

    xsession = {
      enable = true;
      initExtra = ''
        xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
      '';
    };

    home.sessionVariables = {
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1001/bus";
    };
  };

  system.activationScripts.chromeProfile = {
    text = ''
      BACKUP_DIR="/home/jaykchen/chrome-backup"
      CHROME_DIR="/home/jaykchen/.config/google-chrome"

      # Only proceed if backup exists
      if [ -d "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/Local State" ] && [ -d "$BACKUP_DIR/Default" ]; then
        # Ensure chrome directory exists
        mkdir -p "$CHROME_DIR"

        # Copy profile data with error checking
        if ! cp -p "$BACKUP_DIR/Local State" "$CHROME_DIR/"; then
          echo "Failed to copy Local State"
          exit 1
        fi

        if ! cp -pr "$BACKUP_DIR/Default" "$CHROME_DIR/"; then
          echo "Failed to copy Default directory"
          exit 1
        fi

        # Fix permissions
        chown -R jaykchen:users "$CHROME_DIR"
        chmod -R 700 "$CHROME_DIR"
      else
        echo "Chrome backup not found or incomplete - skipping profile restoration"
      fi
    '';
    deps = [ ];
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

  services.dbus.enable = true;

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

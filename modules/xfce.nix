{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://neovim-nightly.cachix.org" ];
    trusted-public-keys = [
      "neovim-nightly.cachix.org-1:feIoInHRevVEplgdZvQDjhp11kYASYCE2NGY9hNrwxY="
    ];
    auto-optimise-store = true;
  };

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
    xfce.xfwm4
    xfce.thunar
    gvfs
    dbus-glib
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
    displayManager = {
      defaultSession = "xfce";
      autoLogin = {
        enable = true;
        user = "jaykchen";
      };
    };
    xserver = {
      updateDbusEnvironment = true;
      enable = true;
      desktopManager.xfce = {
        enable = true;
        noDesktop = false;
        enableXfwm = true;
        enableScreensaver = false;
      };
    };
    ratbagd.enable = true;
  };

  # System-wide XFCE configuration
  environment.etc = {
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source =
      ./xfce-xml/xfce4-keyboard-shortcuts.xml;

    "xdg/autostart/xfce4-clipman-plugin-autostart.desktop".text = ''
      [Desktop Entry]
      Hidden=false
      TryExec=xfce4-clipman
      Exec=xfce4-clipman
    '';

    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-screenshooter.xml".text = ''
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

    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml".text = ''
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

    "xdg/xfce4/terminal/terminalrc".text = ''
      [Configuration]
      ColorForeground=#dcdcdc
      ColorBackground=#2c2c2c
      ColorCursor=#dcdcdc
      ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#729fcf;#ad7fa8;#34e2e2;#eeeeec
      ColorScheme=dark
      ThemeDark=true
    '';
  };

  services.xserver.displayManager.sessionCommands = ''
    # Ensure the symlink exists
    rm -rf ~/.config/xfce4
    ln -s /etc/xdg/xfce4 ~/.config/xfce4
    sleep 2
    systemctl --user import-environment DISPLAY DBUS_SESSION_BUS_ADDRESS
  '';

  system.activationScripts.xfceConfig = {
    text = ''
      # Ensure clean state
      rm -rf /home/jaykchen/.config/xfce4

      # Create symlink for persisted config
      ln -s /etc/xdg/xfce4 /home/jaykchen/.config/xfce4

      # Set up autostart directory
      mkdir -p /home/jaykchen/.config/autostart
      ln -sf /etc/xdg/autostart/xfce4-clipman-plugin-autostart.desktop /home/jaykchen/.config/autostart/

      # Adjust permissions
      chown -R jaykchen:users /home/jaykchen/.config
      chmod -R 755 /home/jaykchen/.config
    '';
  };

  # Rest of the services remain unchanged
  environment.persistence."/nix/persist" = {
    directories = [
      # "/home/jaykchen/.bash_profile"
      "/var/lib/nixos"
      # "/home/jaykchen/.config/google-chrome"
      # "/home/jaykchen/.config/Postman"
      # {
      #   directory = "/home/jaykchen/.bash_profile";
      #   user = "jaykchen";
      #   group = "users";
      #   mode = "0700";
      # }
    ];
  };

  system.activationScripts.postmanConfig = {
    text = ''
      BACKUP_DIR="/home/jaykchen/postman-backup"
      POSTMAN_DIR="/home/jaykchen/.config/Postman"

      # Only proceed if backup exists
      if [ -d "$BACKUP_DIR" ]; then
        # Ensure Postman configuration directory exists
        mkdir -p "$POSTMAN_DIR"

        # Copy configuration data with error checking
        if ! cp -pr "$BACKUP_DIR/." "$POSTMAN_DIR/"; then
          echo "Failed to copy Postman configuration"
          exit 1
        fi

        # Fix permissions
        chown -R jaykchen:users "$POSTMAN_DIR"
        chmod -R 700 "$POSTMAN_DIR"
      else
        echo "Postman backup not found - skipping configuration restoration"
      fi
    '';
    deps = [ ];
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

  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pipewire.extraConfig.pipewire = {
    "10-x11-bell" = {
      "context.modules" = [
        {
          name = "libpipewire-module-x11-bell";
          args.flags = [ "nofail" ];
        }
      ];
    };
  };

  services.dbus = {
    enable = true;
    packages = [ pkgs.seahorse ];
  };

  # services.xserver.updateDbusEnvironment = true;

  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
  };

  services.gnome = {
    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };
}

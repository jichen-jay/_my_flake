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

    # xfconf.settings = {
    #   "xfce4-screenshooter" = {
    #     "/actions/show_in_folder" = false;
    #     "/actions/show_mouse" = true;
    #     "/actions/take_window_shot" = false;
    #     "/app/last_user" = "";
    #     "/default/delay" = 0;
    #     "/default/region" = 3;
    #     "/default/action" = 1;
    #     "/default/show_mouse" = true;
    #     "/default/title" = true;
    #   };

    #   "xfce4-power-manager" = {
    #     "/xfce4-power-manager/show-tray-icon" = false;
    #     "/xfce4-power-manager/power-button-action" = 4;
    #     "/xfce4-power-manager/lock-screen-suspend-hibernate" = false;
    #     "/xfce4-power-manager/dpms-on-ac-off" = 32;
    #     "/xfce4-power-manager/dpms-on-ac-sleep" = 31;
    #     "/xfce4-power-manager/blank-on-ac" = 17;
    #     "/xfce4-power-manager/sleep-button-action" = 3;
    #     "/xfce4-power-manager/hibernate-button-action" = 3;
    #     "/xfce4-power-manager/battery-button-action" = 3;
    #   };

    #   "xfce4-session" = {
    #     "/general/PromptOnLogout" = false;
    #     "/shutdown/LockScreen" = false;
    #     "/chooser/AlwaysDisplay" = false;
    #   };

    #   "pointers" = {
    #     "/Logitech_G604_/RightHanded" = true;
    #     "/Logitech_G604_/ReverseScrolling" = true;
    #     "/Logitech_G604_/Threshold" = 1;
    #     "/Logitech_G604_/Acceleration" = 5.0;
    #   };

    #   "xfce4-clipman" = {
    #     "/settings/add-primary-clipboard" = true;
    #   };
    #   "xfce4-terminal" = {
    #     "/Configuration/ColorForeground" = "#dcdcdc";
    #     "/Configuration/ColorBackground" = "#2c2c2c";
    #     "/Configuration/ColorCursor" = "#dcdcdc";
    #     "/Configuration/ColorPalette" = [
    #       "#000000"
    #       "#cc0000"
    #       "#4e9a06"
    #       "#c4a000"
    #       "#3465a4"
    #       "#75507b"
    #       "#06989a"
    #       "#d3d7cf"
    #       "#555753"
    #       "#ef2929"
    #       "#8ae234"
    #       "#fce94f"
    #       "#729fcf"
    #       "#ad7fa8"
    #       "#34e2e2"
    #       "#eeeeec"
    #     ];
    #     "/Configuration/ColorScheme" = "dark";
    #     "/Configuration/ThemeDark" = true;
    #   };
    # };

    xdg.configFile = {
      "autostart/xfce4-clipman-plugin-autostart.desktop".text = ''
        [Desktop Entry]
        Hidden=false
        TryExec=xfce4-clipman
        Exec=xfce4-clipman
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

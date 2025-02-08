{
  config,
  pkgs,
  lib,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    icewm
    picom # compositor for transparency
    nitrogen # wallpaper manager
    volumeicon # volume control
    networkmanagerapplet
    gnome-themes-extra
    papirus-icon-theme
    dconf
    xdg-utils
    gsettings-desktop-schemas
    glib
    google-chrome
    chromium
    telegram-desktop
    font-manager
    zoom-us
    jetbrains-mono
    (writeScriptBin "theme-switch" ''
      #!${pkgs.bash}/bin/bash
      case "$1" in
        "dark")
          icewm-set-theme "Adwaita-dark"
          ;;
        "light")
          icewm-set-theme "Adwaita"
          ;;
      esac
    '')
  ];

  # Enable core services
  services = {
    gvfs.enable = true;
    # Display manager configuration
    xserver = {
      enable = true;
      updateDbusEnvironment = true;
      
      displayManager = {
        defaultSession = "icewm";
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = "jaykchen";
        };
      };

      # IceWM configuration
      windowManager.icewm = {
        enable = true;
        preferences = {
          TaskBarShowWorkspaces = 1;
          TaskBarShowClock = 1;
          TaskBarShowMailFlag = 0;
          TaskBarShowStartMenu = 1;
          TaskBarShowWindowListMenu = 1;
          TaskBarShowCPUStatus = 1;
          TaskBarShowNetStatus = 1;
          PagerShowPreview = 1;
          Theme = "Adwaita";
          IconTheme = "Papirus";
          DesktopBackgroundImage = "";
          DesktopBackgroundColor = '"rgb(45,45,45)"';
        };
      };
    };

    # Audio configuration
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Program configurations
  programs = {
    dconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    firefox.enable = true;
  };

  # System services
  systemd.user.services = {
    picom = {
      enable = true;
      description = "Picom X11 compositor";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.picom}/bin/picom";
        Restart = "always";
        RestartSec = 3;
      };
    };
  };

  # Autostart applications
  environment.etc."icewm/startup" = {
    text = ''
      #!/bin/sh
      nitrogen --restore &
      volumeicon &
      nm-applet &
      picom &
    '';
    mode = "0755";
  };

  # System persistence
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
    ];
  };

  # Enable core services
  services.dbus.enable = true;
  security.rtkit.enable = true;
  services.printing.enable = true;

  # GNOME keyring integration
  security.pam.services = {
    login.enableGnomeKeyring = true;
    lightdm.enableGnomeKeyring = true;
  };

  services.gnome = {
    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };
}

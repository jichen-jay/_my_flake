{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
    alacritty
    (google-chrome.override {
      commandLineArgs = [
        "--disable-crash-reporter"
        "--no-sandbox"
        "--disable-gpu"
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
    (postman.overrideAttrs (old: {
      postInstall = ''
        wrapProgram $out/bin/postman \
          --add-flags "--no-sandbox --disable-gpu"
      '';
    }))
    chromium
    telegram-desktop
    font-manager
    zoom-us
    jetbrains-mono
  ];

  services = {
    displayManager = {
      defaultSession = "none+icewm";
      autoLogin = {
        enable = true;
        user = "jaykchen";
      };
    };
    gvfs.enable = true;
    xserver = {
      enable = true;
      updateDbusEnvironment = true;
      # displayManager = {
      #   lightdm.enable = true;
      # };
      windowManager.icewm.enable = true; # Remove the preferences section
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
    firefox.enable = true;
  };

  systemd.user.services.picom = {
    enable = true;
    description = "Picom X11 compositor";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.picom}/bin/picom --backend glx"; # Specify the backend here
      Restart = "always";
      RestartSec = 3;
    };
  };

  environment.etc = {
    "icewm/preferences".text = ''
      TaskBarShowWorkspaces=1
      TaskBarShowClock=1
      TaskBarShowMailFlag=0
      TaskBarShowStartMenu=1
      TaskBarShowWindowListMenu=1
      TaskBarShowCPUStatus=1
      TaskBarShowNetStatus=1
      PagerShowPreview=1
      Theme="Adwaita"
      IconTheme="Papirus"
      DesktopBackgroundImage=""
      DesktopBackgroundColor="rgb(45,45,45)"
    '';

    "icewm/startup" = {
      text = ''
        #!/bin/sh
        nitrogen --restore &
        volumeicon &
        nm-applet &
        picom &
      '';
      mode = "0755";
    };
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

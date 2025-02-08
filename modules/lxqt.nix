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
  };

  environment.systemPackages = with pkgs; [
    lxqt.lxqt-session
    lxqt.lxqt-panel
    lxqt.lxqt-config
    lxqt.lxqt-globalkeys
    lxqt.lxqt-notificationd
    lxqt.lxqt-policykit
    lxqt.lximage-qt
    pcmanfm-qt
    alacritty
    btop
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
  ];

  services = {
    gvfs.enable = true;
    displayManager = {
      defaultSession = "lxqt";
      autoLogin = {
        enable = true;
        user = "jaykchen";
      };
    };
    xserver = {
      updateDbusEnvironment = true;
      enable = true;
      desktopManager.lxqt.enable = true;
      windowManager.openbox.enable = true; # LXQt typically uses Openbox as the default window manager.
    };
  };

  system.activationScripts.lxqtConfig = {
    text = ''
      CONFIG_DIR="/home/jaykchen/.config/lxqt"
      SYSTEM_CONFIG_DIR="/run/current-system/sw/share/lxqt"

      # Ensure the target directory exists
      if [ ! -d "$SYSTEM_CONFIG_DIR" ]; then
        echo "Error: Target directory $SYSTEM_CONFIG_DIR does not exist."
        exit 1
      fi

      # Remove existing symlink or directory
      if [ -L "$CONFIG_DIR" ]; then
        rm "$CONFIG_DIR"
      elif [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
      fi

      # Create symlink to system configuration directory
      ln -s "$SYSTEM_CONFIG_DIR" "$CONFIG_DIR"
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.pam.services = {
    login.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
    ];
  };
}

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
    qterminal
    qps
    screengrab
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
      # Ensure clean state for LXQt configuration
      rm -rf /home/jaykchen/.config/lxqt

      # Create symlink for persisted config if needed (optional)
      ln -s /etc/xdg/lxqt /home/jaykchen/.config/lxqt

      # Adjust permissions for the configuration directory
      chown -R jaykchen:users /home/jaykchen/.config/lxqt
      chmod -R 755 /home/jaykchen/.config/lxqt
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

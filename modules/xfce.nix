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
      "https://cache.flox.dev"
      "https://neovim-nightly.cachix.org" # Keeping your existing cachix
    ];
    trusted-public-keys = [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
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
    xfce.xfce4-settings
    gsettings-desktop-schemas
    glib
    google-chrome
    nyxt
    inputs.flox.packages.${pkgs.system}.default

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

  services.xserver.enable = true;
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
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-screenshooter.xml".source =
        ./xfce-xml/xfce4-screenshooter.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-clipman.xml".source = ./xfce-xml/xfce4-clipman.xml;
      "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source =
        ./xfce-xml/xfce4-keyboard-shortcuts.xml;

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

  # Ensure Chrome data directory persists across rebuilds
  # environment.persistence."/nix/persist".directories = [
  #   "/home/jaykchen/.config/google-chrome"
  # ];

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

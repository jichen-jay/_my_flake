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
    keep-outputs = true;
    keep-derivations = true;
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    polkit # Authentication agent
    xdg-desktop-portal-hyprland # Screen sharing, app permissions
    dconf # GTK configuration
    xwayland # X11 app support
    hyprshot
    clipman
    wofi
    gnome-themes-extra
    papirus-icon-theme
    xdg-utils
    gsettings-desktop-schemas
    glib
    kitty
    (google-chrome.override {
      commandLineArgs = [
        "--no-sandbox"
        # "--disable-gpu"
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
      sddm = {
        enable = true;
        wayland.enable = true; # Enable Wayland support in SDDM
      };
    };
    xserver = {
      enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Enable XWayland support
  };

  # Required environment variables for proper Wayland/Electron support
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps hint
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issues
    MOZ_ENABLE_WAYLAND = "1"; # For Firefox, but harmless for Chrome
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
  };

  environment.etc."xdg/kitty/kitty.conf".text = ''
    # Map Ctrl+Right Arrow to send the escape for “forward-word”
    map ctrl+right send_text all "\x1b[1;5C"
    # Map Ctrl+Left Arrow to send the escape for “backward-word”
    map ctrl+left send_text all "\x1b[1;5D"
  '';

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

  # Audio configuration via Pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Core services.
  services.dbus.enable = true;
  security.rtkit.enable = true;
  services.printing.enable = true;

  # GNOME Integration (for keyring and related services).
  security.pam.services = {
    login.enableGnomeKeyring = true;
    lightdm.enableGnomeKeyring = true;
  };

  services.gnome = {
    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };

  # Program integration.
  programs = {
    dconf.enable = true;
    firefox.enable = true;
  };

  # System persistence settings.
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
    ];
  };
}

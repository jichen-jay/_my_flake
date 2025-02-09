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
  };

  environment.etc."xdg/kitty/kitty.conf".text = ''
    # Map Ctrl+Arrow keys to send explicit escape sequences
    map ctrl+right send_text all \x1b[1;5C
    map ctrl+left  send_text all \x1b[1;5D

    # Map Alt+Arrow keys to send the desired sequences:
    # Alt+Right sends ESC followed by 'f'
    map alt+right send_text all \x1bf
    # Alt+Left sends ESC followed by 'b'
    map alt+left  send_text all \x1bb
  '';

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

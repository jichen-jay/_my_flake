{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    keep-outputs = true;
    keep-derivations = true;
  };

  environment.systemPackages = with pkgs; [
    polkit # Authentication agent.
    xdg-desktop-portal-hyprland # Wayland portals for screen sharing and app permissions.
    dconf # GTK configuration.
    xwayland # Support for X11 applications via XWayland.
    wlroots
    wl-clipboard
    wl-clip-persist
    cliphist
    clipse
    grim # Screenshot utility.
    swappy
    certbot
    slurp
    alacritty
    fuzzel # Application launcher.
    gnome-themes-extra # Additional GTK themes.
    papirus-icon-theme
    adwaita-icon-theme
    xdg-utils
    gsettings-desktop-schemas
    glib
    wireshark
    (google-chrome.override {
      commandLineArgs = [
        "--no-sandbox"
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
    (postman.overrideAttrs (old: {
      postInstall = ''
        wrapProgram $out/bin/postman --add-flags "--no-sandbox --disable-gpu"
      '';
    }))
    chromium
    xvfb-run
    telegram-desktop
    font-manager
    zoom-us
    jetbrains-mono
  ];

  services.xserver = {
    enable = true; # Required for input devices and display manager
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps hint
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issues
    MOZ_ENABLE_WAYLAND = "1"; # For Firefox, but harmless for Chrome
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    QT_QPA_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
    # GSK_RENDERER = "ngl";
    PATH = [ "/run/wrappers/bin" ];
  };

  programs.niri = {
    package = pkgs.niri;
  };

  services.displayManager.sessionPackages = [
    (pkgs.stdenv.mkDerivation {
      name = "niri-session";
      buildCommand = ''
        mkdir -p $out/share/wayland-sessions
        cat > $out/share/wayland-sessions/niri.desktop <<EOF
        [Desktop Entry]
        Name=Niri
        Comment=Custom Niri Wayland Session
        Exec=${pkgs.niri}/bin/niri
        Type=Application
        DesktopNames=niri
        EOF
      '';
      passthru = {
        providedSessions = [ "niri" ];
      };
    })
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.groups.wireshark = { };
  users.users.jaykchen.extraGroups = [ "wireshark" ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.dbus.enable = true;
  security.rtkit.enable = true;
  services.printing.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.gnome = {
    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };

  programs.dconf.enable = true;
  programs.firefox.enable = true;

  system.activationScripts.postmanConfig = {
    text = ''
      BACKUP_DIR="/home/jaykchen/postman-backup"
      POSTMAN_DIR="/home/jaykchen/.config/Postman"
      if [ -d "$BACKUP_DIR" ]; then
        mkdir -p "$POSTMAN_DIR"
        if ! cp -pr "$BACKUP_DIR/." "$POSTMAN_DIR/"; then
          echo "Failed to copy Postman configuration"
          exit 1
        fi
        chown -R jaykchen:users "$POSTMAN_DIR"
        chmod -R 700 "$POSTMAN_DIR"
      else
        echo "Postman backup not found - skipping restoration"
      fi
    '';
    deps = [ ];
  };

  system.activationScripts.chromeProfile = {
    text = ''
      BACKUP_DIR="/home/jaykchen/chrome-backup"
      CHROME_DIR="/home/jaykchen/.config/google-chrome"
      if [ -d "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/Local State" ] && [ -d "$BACKUP_DIR/Default" ]; then
        mkdir -p "$CHROME_DIR"
        if ! cp -p "$BACKUP_DIR/Local State" "$CHROME_DIR/"; then
          echo "Failed to copy Local State"
          exit 1
        fi
        if ! cp -pr "$BACKUP_DIR/Default" "$CHROME_DIR/"; then
          echo "Failed to copy Default directory"
          exit 1
        fi
        chown -R jaykchen:users "$CHROME_DIR"
        chmod -R 700 "$CHROME_DIR"
      else
        echo "Chrome backup not found or incomplete - skipping restoration"
      fi
    '';
    deps = [ ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
      "/home/jaykchen/.config/Code"
      "/home/jaykchen/.vscode"
    ];
  };

}


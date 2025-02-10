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
  # Enable experimental features for flakes.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    keep-outputs = true;
    keep-derivations = true;
  };

  # System packages.
  environment.systemPackages = with pkgs; [
    polkit # Authentication agent.
    xdg-desktop-portal-hyprland # Wayland portals for screen sharing and app permissions.
    dconf # GTK configuration.
    xwayland # Support for X11 applications via XWayland.
    wl-clipboard # Clipboard tool compatible with Wayland.
    clipse
    grimshot
    grim # Screenshot utility.
    wofi # Application launcher.
    gnome-themes-extra # Additional GTK themes.
    papirus-icon-theme
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
    telegram-desktop
    font-manager
    zoom-us
    jetbrains-mono
  ];

  # Use SDDM as the display manager with Wayland support.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.displayManager.defaultSession = "niri";
  # Disable the traditional X server since Niri is a native Wayland compositor.
  services.xserver.enable = false;

  # Niri configuration.
  programs.niri = {
    enable = true;
    package = pkgs.niri; # Use the stable package from nixpkgs (override with pkgs.niri-unstable if desired).
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
  security.pam.services.login.enableGnomeKeyring = true;

  services.gnome = {
    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    glib-networking.enable = true;
  };

  programs.dconf.enable = true;
  programs.firefox.enable = true;

  # Activation scripts for external app configurations.
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

  # System persistence directories.
  environment.persistence."/nix/persist" = {
    directories = [ "/var/lib/nixos" ];
  };

}

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
    polkit
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    dconf
    xwayland
    wl-clipboard
    wl-clip-persist
    cliphist
    clipse
    autocutsel
    grim
    swappy
    certbot
    slurp
    alacritty
    sqlite
    fuzzel
    gnome-themes-extra
    papirus-icon-theme
    adwaita-icon-theme
    xdg-utils
    gsettings-desktop-schemas
    glib
    wireshark
    qt5.qtwayland
    qt6.qtwayland
    pipewire
    xwaylandvideobridge
    (google-chrome.override {
      commandLineArgs = [
        "--no-sandbox"
        "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
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

  # Updated xdg.portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
    xdgOpenUsePortal = true;
  };

  systemd.user.services."niri-config" = {
    enable = true;
    description = "Generate Niri config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ~/.config/niri";
      ExecStart = ''
              ${pkgs.coreutils}/bin/cat > ~/.config/niri/config << EOF
        input {
            keyboard {
                xkb {
                    layout = "us"
                }
            }
        }

        window-rule {
            match app-id="clipse"
            open-floating true
            default-column-width { fixed 622; }
            default-window-height { fixed 652; }
        }

        keybinds {
            SUPER+CTRL+F = exec ${pkgs.alacritty}/bin/alacritty --class clipse -e ${pkgs.clipse}/bin/clipse
            SUPER+CTRL+V = exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
        }

        output {
            # You can get your output names from 'niri msg outputs'
            "*" {
                scale = 1.0
            }
        }

        layout {
            # Whether to use gaps between views in the tiling layout
            gaps = 8

            # Whether to add a gap between views and the screen edge
            screen-gap = 8
        }
        EOF
      '';
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.user.services.clipboard-manager = {
    enable = true;
    description = "Clipboard manager service (clipse)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.clipse}/bin/clipse -daemon";
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
      Environment = [
        "WAYLAND_DISPLAY=wayland-0"
        "XDG_RUNTIME_DIR=/run/user/%U"
        "DISPLAY=:0"
      ];
    };
  };

  systemd.user.services.clipboard-history = {
    enable = true;
    description = "Clipboard history service (cliphist and wl-clipboard)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '\
          ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store & \
          ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store & \
          ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both & \
          wait'
      '';
      Type = "simple";
      Restart = "always";
    };
  };

  systemd.user.services.portal-config = {
    enable = true;
    description = "Portal configuration setup";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      mkdir -p ~/.config/systemd/user/xdg-desktop-portal.service.d/
      cat > ~/.config/systemd/user/xdg-desktop-portal.service.d/override.conf << EOF
      [Service]
      Environment="XDG_CURRENT_DESKTOP=niri"
      EOF
      systemctl --user daemon-reload
      systemctl --user restart xdg-desktop-portal.service
    '';
  };

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.displayManager.defaultSession = "niri";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
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

  # Updated dbus configuration
  services.dbus = {
    enable = true;
    packages = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
  };

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

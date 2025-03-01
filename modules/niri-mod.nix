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
    xdg-desktop-portal-wlr
    kicad
    dconf
    xwayland
    wev
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

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      # common = {
      #   default = [
      #     "gtk"
      #     "wlr"
      #   ];
      # };
      niri = {
        default = [
          "gtk"
          "wlr"
        ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
    xdgOpenUsePortal = true;
  };

  programs.thunar.enable = true;
  services.gvfs.enable = true; # For mounting and trash support
  services.tumbler.enable = true; # For thumbnails

  systemd.user.services."niri-config" = {
    enable = true;
    description = "Generate Niri config";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScriptBin "niri-config-script" ''
                mkdir -p $HOME/.config/niri
                cat > $HOME/.config/niri/config <<EOF
        input {
          keyboard {
            xkb {
              layout = "us"
            }
          }
        }

        window-rule {
          match app-id="fuzzel"
          keyboard-interactivity = "exclusive"; # Ensure focus for pop-up windows

          match app-id="clipse"
          open-floating true;
          default-column-width { fixed 622; }
          default-window-height { fixed 652; }
        }

        binds {
          # Toggle shortcut inhibition
          Mod+Escape { toggle-keyboard-shortcuts-inhibit; }

          # Clipboard History
          SUPER+CTRL+F allow-inhibiting=false { spawn "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

          # Screenshot to Clipboard
          SUPER+CTRL+S allow-inhibiting=false { spawn "grim -g \$(slurp) - | wl-copy --type image/png"; }

          # Launch Clip-Based Application (clipse)
          SUPER+ALT+C allow-inhibiting=false { spawn "${pkgs.alacritty}/bin/alacritty --class clipse -e ${pkgs.clipse}/bin/clipse"; }
        }

        output {
          "*" {
            scale = 1.0;
          }
        }

        layout {
          gaps = 8;
          screen-gap = 8;
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
      ExecStart =
        let
          script = pkgs.writeShellScriptBin "clipboard-history-script" ''
            ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch | ${pkgs.cliphist}/bin/cliphist store &
            ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch | ${pkgs.cliphist}/bin/cliphist store &
            wait
          '';
        in
        "${script}/bin/clipboard-history-script"; # <-- Fix path to include /bin/
      Type = "simple";
      Restart = "always";
    };
  };

  systemd.user.services.portal-config = {
    enable = true;
      before = [ "xdg-desktop-portal.service" ];
    description = "Portal configuration setup";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  script = ''
    mkdir -p ~/.config/systemd/user/xdg-desktop-portal.service.d/
    cat > ~/.config/systemd/user/xdg-desktop-portal.service.d/override.conf << EOF
    [Service]
    Environment="XDG_CURRENT_DESKTOP=niri"
    Environment="WAYLAND_DISPLAY=wayland-0"
    EOF
    systemctl --user restart xdg-desktop-portal
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
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
    # XDG_DATA_DIRS = "/run/current-system/sw/share:/home/jaykchen/.nix-profile/share:/nix/profile/share";
    PATH = [ "/run/wrappers/bin" ];
  };

  programs.niri = {
    package = pkgs.niri;
  };

systemd.user.services.niri.serviceConfig.ExecStartPre = [
  "${pkgs.systemd}/bin/systemctl --user import-environment XDG_CURRENT_DESKTOP WAYLAND_DISPLAY"
  "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP=niri"
];


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
      pkgs.xdg-desktop-portal-wlr
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

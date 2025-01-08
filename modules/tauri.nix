{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Build tools
    pkg-config

    # Development packages
    gtk3.dev
    glib.dev
    cairo.dev
    gdk-pixbuf.dev
    pango.dev
    gobject-introspection.dev
    webkitgtk_4_1.dev

    # Core libraries
    gtk3
    glib
    cairo
    gdk-pixbuf
    atk
    dbus
    pango
    openssl_3
    libsoup_3

    # Node.js environment
    nodejs_22
    pnpm

    # Tauri dependencies
    at-spi2-atk
    atkmm
    gobject-introspection
    harfbuzz
    librsvg
    webkitgtk_4_1
    cargo-tauri

    # Rust tools
    rust-analyzer
    rustc
    rustup

    # Additional dependencies
    glib-networking
    gsettings-desktop-schemas
  ];

  environment.sessionVariables = {
    PKG_CONFIG_PATH =
      with pkgs;
      lib.concatStringsSep ":" [
        "${webkitgtk_4_1.dev}/lib/pkgconfig"
        "${librsvg.dev}/lib/pkgconfig"
        "${gtk3.dev}/lib/pkgconfig"
        "${glib.dev}/lib/pkgconfig"
        "${cairo.dev}/lib/pkgconfig"
        "${pango.dev}/lib/pkgconfig"
        "${gdk-pixbuf.dev}/lib/pkgconfig"
        "${gobject-introspection.dev}/lib/pkgconfig"
      ];

    LD_LIBRARY_PATH =
      with pkgs;
      lib.makeLibraryPath [
        webkitgtk_4_1
        gtk3
        cairo
        gdk-pixbuf
        glib
        dbus
        openssl_3
        librsvg
      ];
      
    XDG_DATA_DIRS = lib.mkForce (
      with pkgs;
      lib.concatStringsSep ":" [
        "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
        "${gtk3}/share/gsettings-schemas/${gtk3.name}"
        "/nix/store/zy2d9l86q8bhs16cq7ywba5pp5v5q7q7-desktops/share"
        "$XDG_DATA_DIRS"
      ]
    );

    GI_TYPELIB_PATH =
      with pkgs;
      lib.makeSearchPath "lib/girepository-1.0" [
        gtk3
        glib
        gobject-introspection
        webkitgtk_4_1
        librsvg
      ];
  };

  environment.shellInit = ''
    if command -v rustup >/dev/null 2>&1; then
      rustup default stable
      rustup target add wasm32-unknown-unknown
      rustup target add wasm32-wasi
      rustup target add wasm32-wasip1
      rustup target add wasm32-wasip2
    fi
  '';
}

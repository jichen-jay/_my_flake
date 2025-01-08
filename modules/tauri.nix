{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkg-config
    cmake
    ninja

    gtk3
    gtk3.dev
    glib
    glib.dev
    gobject-introspection
    cairo
    cairo.dev
    gdk-pixbuf
    atk
    pango

    cargo-tauri
    rust-analyzer
    rustc
    rustup
  ];

  # Ensure pkg-config can find the development files
  environment.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.gtk3.dev}/lib/pkgconfig:${pkgs.glib.dev}/lib/pkgconfig:${pkgs.cairo.dev}/lib/pkgconfig";
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

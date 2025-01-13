{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1. Overlay to fix webkitgtk "4.1" pkg-config mismatch:
  nixpkgs.overlays = [
    (final: prev: {
      webkitgtk_4_1_fixed = prev.webkitgtk_4_1.dev.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          # Symlink so pkg-config finds "webkit2gtk-4.1.pc"
          ln -s $out/lib/pkgconfig/webkit2gtk-4.0.pc \
                $out/lib/pkgconfig/webkit2gtk-4.1.pc
        '';
      });
    })
  ];

  # 2. System packages: Tauri wants Rust + node + WebKit.
  #    We'll also include cargo-tauri (for "cargo tauri" commands) and
  #    some common GTK dependencies if your Tauri app uses them.
  environment.systemPackages = with pkgs; [
    # Rust + dev tools
    rustc
    cargo
    cargo-tauri
    nodejs
    pkg-config

    # For Tauri’s “webkit2gtk-4.1” check:
    webkitgtk_4_1 # runtime libs
    webkitgtk_4_1_fixed # dev output with "webkit2gtk-4.1.pc"
    librsvg

    # Common GTK dependencies:
    gtk3
    gobject-introspection
    libsoup_3
    cairo
    pango
    glib
    openssl

    # (Optional) If you want to manage Rust toolchains with rustup:
    rustup
    rust-analyzer
  ];

  # 3. Minimal environment variables.
  #    Usually, Tauri can detect libs without these, but you might keep PKG_CONFIG_PATH
  #    if you run pkg-config based checks.
  environment.sessionVariables = {
    # Make sure pkg-config sees the newly-symlinked "webkit2gtk-4.1.pc"
    PKG_CONFIG_PATH = lib.makeSearchPathOutput "lib" "pkgconfig" [
      pkgs.webkitgtk_4_1_fixed
    ];

    # If you encounter GPU issues, disabling DMA buf rendering can help:
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };

  # 4. DBus + dconf services are often required by GTK apps:
  services.dbus.enable = true;
  programs.dconf.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ zlib ];

  # 5. (Optional) Shell init for `rustup`:
  environment.shellInit = ''
    if command -v rustup >/dev/null 2>&1; then
      rustup default stable
      rustup component add rust-src rust-analyzer
    fi
  '';
}

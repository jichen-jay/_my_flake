{ pkgs
, lib
, ...
}:

{
  fonts.fontDir.enable = true;

  # Fonts Configuration
  fonts.packages = with pkgs; [
    font-manager
    jetbrains-mono
    source-han-mono
    source-han-sans
    source-han-serif
    noto-fonts-cjk-sans
    # Mono fonts
    (nerdfonts.override {
      fonts = [
        "IBMPlexMono"
      ];
    })

  ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "DejaVu Serif" "Source Han Serif SC" ];
        sansSerif = [ "DejaVu Sans" "Source Han Sans SC" ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [ "BlexMono Nerd Font Mono" "Source Han Mono SC" "JetBrains Mono" ];
      };
    };
    enableDefaultPackages = true;
  };
}

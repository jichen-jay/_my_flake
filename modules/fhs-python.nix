# /home/jaykchen/_my_flake/modules/fhs-python.nix
{ pkgs, ... }:

{
  # Enable FHS User Env
  programs.nix-ld.enable = true;

  # Libraries needed for FHS Python and its packages
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    bzip2 # Often needed for Python packages
    libffi # Foreign Function Interface, used by some Python libs
    ncurses # For terminal-based applications
    readline # For interactive input in Python
    xz # Another compression library sometimes needed
  ];

  environment.systemPackages = with pkgs; [
    fhs
    uv
    python311
  ];
}

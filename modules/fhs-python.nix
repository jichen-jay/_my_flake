# /home/jaykchen/_my_flake/modules/fhs-python.nix
{ pkgs, ... }:

let
  myFhs = pkgs.buildFHSEnv {
    name = "fhs-python-env";
    targetPkgs = pkgs: (with pkgs; [
      python311
    ]);
    runScript = "bash"; # or any other shell you want
  };
in
{

  programs.nix-ld.enable = true;

  # Libraries needed for FHS Python and its packages, use pkgs.nix-ld.libPath
  programs.nix-ld.libraries = with pkgs; [
    # Core libraries are typically in nix-ld's libPath, include if needed
  ] ++ lib.optionals stdenv.isLinux [
    # Other Linux-specific libraries
    stdenv.cc.cc.lib
    zlib
    openssl
    bzip2
    libffi
    ncurses
    readline
    xz
  ];

  environment.systemPackages = [
    pkgs.uv
    myFhs
    pkgs.nix-ld
  ];
}

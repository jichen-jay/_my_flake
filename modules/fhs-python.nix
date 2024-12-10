# /home/jaykchen/_my_flake/modules/fhs-python.nix
{ pkgs, ... }:

let
  myFhs = pkgs.buildFHSUserEnv {
    name = "fhs-python-env";
    targetPkgs = pkgs: (with pkgs; [
      python311
    ]);
    runScript = "bash"; # or any other shell you want
  };
in
{
  # Libraries needed for FHS Python and its packages
  programs.nix-ld.libraries = with pkgs; [
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
  ];
}

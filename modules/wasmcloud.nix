{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage (fetchFromGitHub {
      owner = "wasmCloud";
      repo = "wasmCloud";
      rev = "v0.37.0";
      sha256 = "0xhyqw9lxcg8azvc92bk0zrzv9wi4zcrlbkmkxs5la63086w0xdi";

    }) { }).wash-cli
  ];
}

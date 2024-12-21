{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.stdenv.mkDerivation {
      pname = "wash-cli";
      version = "0.37.0";
      src = pkgs.fetchurl {
        url = "https://github.com/wasmCloud/wasmCloud/releases/download/wash-cli-v0.37.0/wash-x86_64-unknown-linux-musl";
        sha256 = "0xhyqw9lxcg8azvc92bk0zrzv9wi4zcrlbkmkxs5la63086w0xdi";

      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/wash
        chmod +x $out/bin/wash
      '';
    })
    (pkgs.stdenv.mkDerivation {
      pname = "wrpc-wasmtime";
      version = "0.14.0";
      src = pkgs.fetchurl {
        url = "https://github.com/bytecodealliance/wrpc/releases/download/v0.14.0/wrpc-wasmtime-x86_64-unknown-linux-musl";
        sha256 = "1j1zfy8lc3219fc310jjjn1a4g16xflvnk0g5zhpqq90vhwamrgd";
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/wrpc-wasmtime
        chmod +x $out/bin/wrpc-wasmtime
      '';
    })

  ];
}

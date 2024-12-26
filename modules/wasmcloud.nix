{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    netcat
    socat
    tcpdump
    # wireshark

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
      pname = "wasmtime";
      version = "28.0.0";
      src = pkgs.fetchurl {
        url = "https://github.com/bytecodealliance/wasmtime/releases/download/v28.0.0/wasmtime-v28.0.0-x86_64-musl.tar.xz";
        sha256 = "0gbkzhg0p9qn1vczap6pfs2xmp9vpj5mxhm1jbx33fc4syazrrxn";
      };

      unpackPhase = ''
        mkdir -p source
        tar xf $src -C source
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp source/wasmtime-v${version}-x86_64-musl/wasmtime $out/bin/
        chmod +x $out/bin/wasmtime
      '';
    })
    (pkgs.stdenv.mkDerivation {
      pname = "wac";
      version = "0.6.1";
      src = pkgs.fetchurl {
        url = "https://github.com/bytecodealliance/wac/releases/download/v0.6.1/wac-cli-x86_64-unknown-linux-musl";
        sha256 = "0cafjsa2lcaczavbpzicyksmsn5vqzlycgwfmc6dz4mqpg4adgx2";
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/wac
        chmod +x $out/bin/wac
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

    websocat
    mtr
    nmap
  ];
}

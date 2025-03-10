{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wasm-tools
    wabt
    # wireshark

    (pkgs.stdenv.mkDerivation {
      pname = "texter";
      version = "0.1.1";
      src = pkgs.fetchurl {
        url = "https://github.com/jichen-jay/texter/releases/download/main/texter";
        sha256 = "0qvs1xwn3p40p1n51vv87i3v3ppdx9gdf34n7cii4zyypgqsmngn"; 
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/texter
        chmod +x $out/bin/texter
      '';
    })
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
      pname = "spin";
      version = "3.1.1";
      src = pkgs.fetchurl {
        url = "https://github.com/fermyon/spin/releases/download/v3.1.1/spin-v3.1.1-static-linux-amd64.tar.gz";
        sha256 = "0yfjnrdn4hkvy45639r7cimhs52z27y3fjkg8dz21q7pdslbfpnb";
      };
      dontUnpack = true; # Prevent the automatic unpacking
      installPhase = ''
        mkdir -p $out/bin
        tar -xzf $src -C $out/bin
        chmod +x $out/bin/spin
      '';
    })
    (rustPlatform.buildRustPackage rec {
      pname = "wasmtime";
      version = "27.0.0";

      src = fetchFromGitHub {
        owner = "bytecodealliance";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-Xqj680MZ8LpBChEU0ia+GGjSceRM55tF5uWJLMuBuQ0=";
        fetchSubmodules = true;
      };

      # Disable cargo-auditable until https://github.com/rust-secure-code/cargo-auditable/issues/124 is solved.
      auditable = false;
      cargoHash = "sha256-qpPXP815kpIIFOiQQDUUgI5blRV1ly2it/XC09UnmVU=";

      cargoBuildFlags = [
        "--package"
        "wasmtime-cli"
      ];

      nativeBuildInputs = [
        cmake
        rustfmt
      ];

      doCheck = false; # Keep this false unless you want to run tests

      meta = with lib; {
        description = "Standalone JIT-style runtime for WebAssembly, using Cranelift";
        homepage = "https://wasmtime.dev/";
        license = licenses.asl20;
        mainProgram = "wasmtime";
        maintainers = with maintainers; [
          ereslibre
          matthewbauer
        ];
        platforms = platforms.unix;
        changelog = "https://github.com/bytecodealliance/wasmtime/blob/v${version}/RELEASES.md";
      };
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

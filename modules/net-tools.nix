{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    natscli
    inetutils
    netcat
    lsof
    socat
    tcpdump
    xca
    openssl
    # (rustPlatform.buildRustPackage rec {
    #   pname = "quiche";
    #   version = "0.23.2";

    #   src = fetchFromGitHub {
    #     owner = "cloudflare";
    #     repo = pname;
    #     rev = "v${version}";
    #     sha256 = "1fy2d9k1981igd0qdbzd7sh903jqbrhs994wa831ca180z77saj8";
    #     fetchSubmodules = true;
    #   };

    #   postPatch = ''
    #     cargo generate-lockfile
    #   '';

    #   nativeBuildInputs = [
    #     cmake
    #     rustfmt
    #     pkg-config
    #   ];

    #   buildInputs = [
    #     openssl
    #   ];

    #   cargoLock = {
    #     lockFileContents = builtins.readFile ./Cargo.lock;
    #     outputHashes = {
    #       "quiche-0.23.2" = "sha256-xxxxx";
    #     };
    #   };

    #   buildPhase = ''
    #     cargo build --bin h3i --release
    #   '';

    #   installPhase = ''
    #     mkdir -p $out/bin
    #     cp target/release/h3i $out/bin/
    #     chmod +x $out/bin/h3i
    #   '';

    #   doCheck = false;
    # })

  ];

  security.wrappers.tcpdump = {
    source = "${pkgs.tcpdump}/bin/tcpdump";
    capabilities = "cap_net_raw,cap_net_admin=eip";
    owner = "root"; # Add this line
    group = "root"; # Best practice to also specify group
  };

  # environment.etc."nats/nats-server.conf".text = ''
  #   # Client connections
  #   port: 4222

  #   # HTTP monitoring port
  #   http_port: 8222

  #   # Debugging options
  #   debug: true
  #   trace: true

  #   # Log file
  #   log_file: "/var/log/nats-server.log"
  # '';

}

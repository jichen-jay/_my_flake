{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    natscli
    inetutils
    postman
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

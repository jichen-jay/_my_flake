{ config
, pkgs
, ...
}: {
  environment.systemPackages = with pkgs; [
    wash-cli
    nats-server
    natscli
    inetutils
    postman
    steam-run
  ];

  systemd.services.nats = {
    description = "NATS Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.nats-server}/bin/nats-server";
      Restart = "always";
      Type = "simple";
    };
  };
  
environment.etc."nats/nats-server.conf".text = ''
  # Client connections
  port: 4222
  
  # HTTP monitoring port
  http_port: 8222
  
  # Debugging options
  debug: true
  trace: true
  
  # Log file
  log_file: "/var/log/nats-server.log"
'';

}

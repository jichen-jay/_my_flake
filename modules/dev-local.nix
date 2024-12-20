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

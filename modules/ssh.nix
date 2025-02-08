{
  config,
  pkgs,
  lib,
  ...
}:
{
  # System-level SSH daemon configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      AllowTcpForwarding = true;
      AllowStreamLocalForwarding = true;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = false;
    };
  };

  # Enable ssh-agent
  programs.ssh.startAgent = true;

  # System-wide SSH configuration
  environment.etc."ssh/ssh_config".text = ''
    ObscureKeystrokeTiming no
    Host mac
      HostName 10.0.0.123
      User jichen    

    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/alt_git

    Host b550 md16 pn53
      User jaykchen
      IdentityFile /home/jaykchen/.ssh/nixos_ed25519
      ForwardAgent yes
      AddKeysToAgent yes
      Compression yes
      ServerAliveInterval 60

    Host b550
      HostName 10.0.0.129

    Host md16
      HostName 10.0.0.40

    Host pn53
      HostName 10.0.0.218

    Host sg
      User root
      HostName 43.134.33.29
      IdentityFile ~/.ssh/pn53_id_rsa
      ForwardAgent yes
      AddKeysToAgent yes
      Compression yes
      ServerAliveInterval 60

    Host sv
      User root
      HostName 43.130.1.178
      IdentityFile ~/.ssh/nixos_ed25519
      ForwardAgent yes
      AddKeysToAgent yes
      Compression yes
      ServerAliveInterval 60
  '';

  # Ensure SSH directory exists with correct permissions
  system.activationScripts.sshUserDir = ''
    mkdir -p /home/jaykchen/.ssh
    chown jaykchen:users /home/jaykchen/.ssh
    chmod 700 /home/jaykchen/.ssh
  '';
}

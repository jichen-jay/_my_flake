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

  # If you want to use ssh-agent
  programs.ssh.startAgent = true;

  # User SSH configuration should go in home-manager config
  home-manager.users.jaykchen =
    { pkgs, ... }:
    {
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host mac
            HostName 10.0.0.123
            User jichen    

          Host github.com
            HostName github.com
            User git
            IdentityFile ~/.ssh/alt_git

          Host b550 md16
            User jaykchen
            IdentityFile ~/.ssh/pn53_id_rsa
            ForwardAgent yes
            AddKeysToAgent yes
            Compression yes
            ServerAliveInterval 60

          Host b550
            HostName 10.0.0.129

          Host md16
            HostName 10.0.0.40

          Host sg
            User root
            HostName 43.134.33.29
            IdentityFile ~/.ssh/sg_rsa
            ForwardAgent yes
            AddKeysToAgent yes
            Compression yes
            ServerAliveInterval 60
        '';
      };
    };

  users.users = {
    jaykchen.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxv0E+eDCgj7DgjWQJD7NvvjXAj2ZMIVT0gYP5PkvIz jaykchen@nixos"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCskmS2vKyKo0tt5rfgrEveKM0mfxTSoSgJ7wADFm+k78EidC0zvP2+YhC28eU6Xyn1VRimDnvN0Gf76o+A6wudb2lDDi95Nm0WH3wexlVkCVZel/eUBR8ubyHJuzX0E7hiFNjxtzXnQ9ZUvrUViirfBaOBk78Ie5nn/F62HNcG9sv3V5p5fLvbCpjDWWY0aFZePm064cSRZUgSfo0kCaeFtARKpVUGzBtFDE7FSfaL1ORK+vEsqtwkf+dfrP6Cep0b99wKXz6TK38L6AdgJHfM4a8CWNB6UoX69a81vRBMxK6hUEFW+HYQ0aOF5PdtWi4PDpe1P85mFwhH0cvHPvG0yqOAutEUSWzaGtzNTkXJnFpnN+p7fMZQ1f4NBnl4/FObQgUbPVARyqggl/VoZJ4XjBtxmiq0dDQQ1Epny2OOSzbGyn7xxjUmMnL22/LLPQfiSXMW2YMKnsQH80nERFxfcZhyYvev5edmPzdDBi6kSOlmjC/pJOXGQkfSbTsPtUN3WmGP1pWSKHV1/h2WFuBNGBubsPQtj2ThYjgfYR+8tITMMEjLeIi11+abDKjEQBD2HXwJOmV7P4DYv9TmnKqPtJURwJ0olpxAGooTDR5C16Nv/gWQ4Qa6L+WXOKztiTiv3PhU+U+DERvJiobQdTxIiFyBH0c1cOPq/fcz+n8cDw== jaykchen@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9j5UpZ/x60v/ZQ0VZKiT/d6KZf9+IudBCGWM6NubGgKvyU8sk01TB00+8hpKNbbsU/ypNE2bJTy/ZpRaMpfy8GA04RHL+lKRUydXL0RPKWyiz00/1rVKtoQBZLblsQGgmDQkI4CsDdHtc9rmV+egsas+BLmKeNej/q24/AADZKz5W+DQJGl5kEo/xZb9BkTgWYPjB+VOoY2uTcSCm1rE1HJu7XPh6K1GS+RCKujGYHkMw00ol1Q4jQQMVJdrrafKbK9U6VwQQUg6eDsgmbgryepSg60PqpcP2pNdovQtcaYD2f2IskhdSq+y1GqSIyu4ZKXDYpydaf2YLHfAjBo2h skey-hhzr6xgf"
    ];
    root.openssh.authorizedKeys.keys = config.users.users.jaykchen.openssh.authorizedKeys.keys;
  };
}

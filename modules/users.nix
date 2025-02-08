{
  config,
  lib,
  pkgs,
  ...
}:
let
  mySSHKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTIZhL/Hy0JxO1SJAUW9LyFkhp61qMSeJ90xB9G045g jaykchen@nixos"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCskmS2vKyKo0tt5rfgrEveKM0mfxTSoSgJ7wADFm+k78EidC0zvP2+YhC28eU6Xyn1VRimDnvN0Gf76o+A6wudb2lDDi95Nm0WH3wexlVkCVZel/eUBR8ubyHJuzX0E7hiFNjxtzXnQ9ZUvrUViirfBaOBk78Ie5nn/F62HNcG9sv3V5p5fLvbCpjDWWY0aFZePm064cSRZUgSfo0kCaeFtARKpVUGzBtFDE7FSfaL1ORK+vEsqtwkf+dfrP6Cep0b99wKXz6TK38L6AdgJHfM4a8CWNB6UoX69a81vRBMxK6hUEFW+HYQ0aOF5PdtWi4PDpe1P85mFwhH0cvHPvG0yqOAutEUSWzaGtzNTkXJnFpnN+p7fMZQ1f4NBnl4/FObQgUbPVARyqggl/VoZJ4XjBtxmiq0dDQQ1Epny2OOSzbGyn7xxjUmMnL22/LLPQfiSXMW2YMKnsQH80nERFxfcZhyYvev5edmPzdDBi6kSOlmjC/pJOXGQkfSbTsPtUN3WmGP1pWSKHV1/h2WFuBNGBubsPQtj2ThYjgfYR+8tITMMEjLeIi11+abDKjEQBD2HXwJOmV7P4DYv9TmnKqPtJURwJ0olpxAGooTDR5C16Nv/gWQ4Qa6L+WXOKztiTiv3PhU+U+DERvJiobQdTxIiFyBH0c1cOPq/fcz+n8cDw== jaykchen@gmail.com"
  ];
in
{
  users.users = {
    root = {
      # Re-use the same SSH keys.
      openssh.authorizedKeys.keys = mySSHKeys;
      hashedPassword = "$6$xyz$OrO5YWK4q.qdzicSQLj7DE50ehM.7L6J5hKp0OEtNorusLTyMqOtPl2IxFUJgxqCP07CYNppkbo2pbVBUbRT41";
    };

    jaykchen = {
      isNormalUser = true;
      description = "jaykchen";
      extraGroups = [
        "networkmanager"
        "wheel"
        "podman"
        "docker"
        "storage"
        "users"
      ];
      createHome = true;
      home = "/home/jaykchen";
      group = "users";
      shell = pkgs.zsh;
      linger = true;
      hashedPassword = "$6$xyz$UrgZzIZfEDMHk86dA6yezb9kXPsMxSHYEgXUXKRJbg6Ls.LNON3w27FHjHMRgtGrulLWdlUYfODiumnEOAMD80";
      openssh.authorizedKeys.keys = mySSHKeys;

      # Additional container namespacing settings if needed.
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };

  };
  programs.zsh.enable = true;
}

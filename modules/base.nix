# ./modules/base.nix
{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      trusted-users = [
        "root"
        "@wheel"
        "jaykchen"
      ];
    };
  };

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.jaykchen = {

      home.stateVersion = "24.11";
      imports = [ ../home.nix ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.bash = {
        enable = true;
        initExtra = ''
          eval "$(direnv hook bash)"
          source $HOME/.nix-profile/share/nix-direnv/direnvrc
        '';
      };
    };
  };

  system.stateVersion = "24.11";
}

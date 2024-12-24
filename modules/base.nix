# ./modules/base.nix
{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package =pkgs.nix;
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
    };
  };

  system.stateVersion = "24.11";
}

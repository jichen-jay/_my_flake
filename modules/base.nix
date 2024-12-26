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

  system.stateVersion = "24.11";
}

# /home/jaykchen/_my_flake/configuration.nix

{ config, pkgs, ... }:

{ 
imports = [

./hardware-configuration.nix
];


services.vscode-server.enable = true;

}

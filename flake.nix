# /home/jaykchen/_my_flake/flake.nix
{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nixos-vscode-server, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./modules/system.nix
          ./modules/dark-theme.nix
          ./modules/access-shared-drive.nix
          ./modules/intel-gpu.nix
          ./modules/services.nix
          ./modules/users.nix
          nixos-vscode-server.nixosModules.default
        ];
      };
    };
}

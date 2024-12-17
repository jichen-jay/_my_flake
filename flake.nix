{
  description = "NixOS configuration with flakes and Home Manager options";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    inputs@{ nixpkgs, ... }:

    let
      # Base modules for all systems
      baseModules = [
        ./modules/users.nix
        ./modules/base.nix
        ./modules/ssh.nix
        ./modules/virt.nix
        ./modules/services.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-vscode-server.nixosModules.default
      ];

      # Desktop-specific modules
      desktopModules = [
        ./modules/printer.nix
        ./modules/font.nix
        ./modules/dev-local.nix
        ./modules/dark-theme.nix
        ./modules/desktop-entry.nix
        ./modules/access-shared-drive.nix
        ./modules/vscode.nix
      ];

      mkHost =
        {
          system,
          hostName,
          isDesktop ? true,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules =
            baseModules
            ++ (if isDesktop then desktopModules else [ ])
            ++ extraModules
            ++ [
              {
                networking.hostName = hostName;
              }
            ];
        };
    in
    {
      nixosConfigurations = {
        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

        pn53 = mkHost {
          system = "x86_64-linux";
          hostName = "pn53";
          extraModules = [ ./modules/hardware-configuration-pn53.nix ];
        };

        md16 = mkHost {
          system = "x86_64-linux";
          hostName = "md16";
          extraModules = [
            ./modules/hardware-configuration-md16.nix
            ./modules/intel-gpu.nix
          ];
        };

        cloud = mkHost {
          system = "x86_64-linux";
          hostName = "cloud";
          isDesktop = false;
          extraModules = [
            # ./modules/hardware-configuration-cloud.nix
            # ./modules/cloud-specific.nix
          ];
        };
      };
    };
}

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
    inputs@{ nixpkgs, nixpkgs-unstable, ... }:

    let

      overlay = final: prev: {
        vscode = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.vscode-fhs;
        vscode-with-extensions = (
          inputs.nixpkgs-unstable.legacyPackages.${prev.system}.vscode-with-extensions.override {
            vscodeExtensions =
              with inputs.nixpkgs-unstable.legacyPackages.${prev.system}.vscode-extensions;
              [
                esbenp.prettier-vscode
                brettm12345.nixfmt-vscode
              ]
              ++
                inputs.nixpkgs-unstable.legacyPackages.${prev.system}.vscode-utils.extensionsFromVscodeMarketplace
                  [
                    {
                      name = "solarized-chandrian";
                      publisher = "JackKenney";
                      version = "2.2.1";
                      sha256 = "1zk21rja7wa6zi67vz05xs7w0b9gkl8ysaw8hbm6rj8j1rbp4bq7";
                    }
                  ];
          }
        );
      };

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
        ./modules/wasmcloud.nix
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
                time.timeZone = "America/Toronto";
                nixpkgs.overlays = [ overlay ];
                nixpkgs.config.allowUnfree = true;

                # Add this home-manager configuration
                home-manager.users.jaykchen = {
                  nixpkgs.config.allowUnfree = true;
                  home.stateVersion = "24.11";
                };
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
          hostName = "VM-0-11-debian";
          isDesktop = false;
          extraModules = [
            ./modules/hardware-configuration-sg.nix
            {
              boot.tmp.cleanOnBoot = true;
              zramSwap.enable = true;
              networking.domain = "localdomain";
              # system.stateVersion = "24.11";
              home-manager.users.root =
                { pkgs, ... }:
                {
                  home.stateVersion = "24.11";
                  home.packages = with pkgs; [ git ];
                  programs.git.enable = true;
                };
            }
            # ./modules/cloud-specific.nix
          ];
        };
      };
    };
}

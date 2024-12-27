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
        ./modules/podman.nix
        ./modules/services.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-vscode-server.nixosModules.default
      ];

      # Desktop-specific modules
      desktopModules = [
        ./modules/xfce.nix
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
                home-manager = {
                  backupFileExtension = "bkp";
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.jaykchen =
                    { pkgs, config, ... }:
                    {
                      imports = [
                        ./home.nix
                        ./modules/zsh.nix
                      ];
                      
                      programs.home-manager.enable = true;
                      home.sessionVariables = {
                        SHELL = "${pkgs.zsh}/bin/zsh";
                      };

                      home.packages = with pkgs; [
                        fzf
                      ];
                    };
                };
              }
              {
                systemd.tmpfiles.rules = [
                  "d /home/jaykchen/.local 0700 jaykchen users"
                  "d /home/jaykchen/.local/share 0700 jaykchen users"
                  "d /home/jaykchen/.local/share/direnv 0700 jaykchen users"
                ];
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
          isDesktop = false;
          extraModules = [
            ./modules/hardware-configuration-pn53.nix
            {
              boot.tmp.cleanOnBoot = true;
              home-manager.users.root =
                { pkgs, ... }:
                {
                  home.stateVersion = "24.11";
                  home.packages = with pkgs; [ git ];
                  programs.git = {
                    enable = true;
                    lfs.enable = true;
                    userName = "jaykchen@icloud.com";
                    userEmail = "jaykchen@icloud.com";
                  };

                };
            }
          ];
        };

        nr200 = mkHost {
          system = "x86_64-linux";
          hostName = "nr200";
          extraModules = [ ./modules/hardware-configuration-nr200.nix ];
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
                  programs.git = {
                    enable = true;
                    lfs.enable = true;
                    userName = "jaykchen@icloud.com";
                    userEmail = "jaykchen@icloud.com";
                  };

                };
            }
            # ./modules/cloud-specific.nix
          ];
        };
      };
    };
}

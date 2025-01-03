{
  description = "NixOS configuration with flakes and Home Manager options";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      baseModules = [
        ./modules/users.nix
        ./modules/base.nix
        ./modules/ssh.nix
        ./modules/podman.nix
        ./modules/services.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-vscode-server.nixosModules.default
      ];

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
        {
          services.xserver = {
            enable = true;
            displayManager.lightdm.enable = true;
            xkb.layout = "us";
            xkb.variant = "";
          };
        }
      ];

      commonGitConfig = {
        enable = true;
        lfs.enable = true;
        userName = "jaykchen@icloud.com";
        userEmail = "jaykchen@icloud.com";
        extraConfig = {
          core = {
            askPass = "";
          };
        };
      };

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
                  extraSpecialArgs = { inherit inputs; };

                  users.jaykchen =
                    { pkgs, config, ... }:
                    {
                      imports = [
                        ./home.nix
                        ./modules/zsh.nix
                      ];
                      home.stateVersion = "24.11";
                      programs.home-manager.enable = true;
                      home.sessionVariables = {
                        SHELL = "${pkgs.zsh}/bin/zsh";
                      };

                      home.packages = with pkgs; [
                        fzf
                      ];

                      programs.git = commonGitConfig;
                    };
                };
              }
              {
                systemd.tmpfiles.rules = [
                  "d /home/jaykchen/.config 0700 jaykchen users"
                  "d /home/jaykchen/.cache 0700 jaykchen users"
                  "d /home/jaykchen/.local/state 0700 jaykchen users"
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
                  programs.git = commonGitConfig;
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

        b550 = mkHost {
          system = "x86_64-linux";
          hostName = "b550";
          isDesktop = false;
          extraModules = [
            (
              { lib, pkgs, ... }:
              {
                # Preserve Ubuntu's boot and hardware settings
                boot.loader.systemd-boot.enable = lib.mkForce false;
                boot.loader.grub.enable = lib.mkForce false;
                boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

                # Disable NixOS hardware configuration
                hardware.enableAllFirmware = lib.mkForce false;
                # Add initrd configuration
                boot.initrd = {
                  enable = true;
                  systemd.enable = true;
                };

                # Add kernel and initrd settings
                boot.kernelPackages = pkgs.linuxPackages_latest;
                boot.supportedFilesystems = [ "ext4" ];
                # Keep Ubuntu's networking configuration
                networking = {
                  hostName = "b550";
                  networkmanager.enable = lib.mkForce false;
                };

                # Filesystem configuration
                fileSystems = {
                  "/" = {
                    device = "/dev/disk/by-uuid/ecac3106-73a9-4395-ba0e-8f40b13b8744";
                    fsType = "ext4";
                  };

                  "/boot" = {
                    device = "/dev/disk/by-uuid/A620-DE8C";
                    fsType = "vfat";
                    options = [
                      "noauto"
                      "nofail"
                    ]; # Add safety options
                  };
                };

                # Disable NixOS system-level services that Ubuntu handles
                systemd.services = {
                  NetworkManager = lib.mkForce { };
                  systemd-udevd = lib.mkForce { };
                  systemd-journald = lib.mkForce { };
                  systemd-logind = lib.mkForce { };
                };

              }
            )
          ];
        };

        cloud = mkHost {
          system = "x86_64-linux";
          hostName = "VM-0-11-debian";
          isDesktop = false;
          extraModules = [
            ./modules/hardware-configuration-sg.nix
            {
              nixpkgs.config.allowUnfree = true;
              boot.tmp.cleanOnBoot = true;
              zramSwap.enable = true;
              networking.domain = "localdomain";
              home-manager.users.root =
                { pkgs, ... }:
                {
                  home.stateVersion = "24.11";
                  home.packages = with pkgs; [ git ];
                  programs.git = commonGitConfig;
                };
            }
          ];
        };
      };

      homeConfigurations = {
        "jaykchen@b550" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home.nix
            ./modules/zsh.nix
            (
              { pkgs, ... }:
              {
                home = {
                  username = "jaykchen";
                  homeDirectory = "/home/jaykchen";
                  stateVersion = "24.11";
                };
                programs.git = commonGitConfig;
                home.packages = with pkgs; [
                  lunarvim
                  podman
                  podman-compose
                  podman-tui
                  netavark
                ];
              }
            )
          ];
        };
      };
    };
}

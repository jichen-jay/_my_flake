{
  description = "NixOS configuration with flakes, optimized for Zsh, Home Manager, and VSCode Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixos-vscode-server,
      flake-utils,
      ...
    }:
    let
      pkgsForSystem = system: import nixpkgs { inherit system; };

      baseModules = [
        ./modules/users.nix
        ./modules/base.nix
        ./modules/ssh.nix
        ./modules/podman.nix
        ./modules/services.nix
      ];

      desktopModules = [
        ./modules/xfce.nix
        ./modules/printer.nix
        ./modules/font.nix
        ./modules/net-tools.nix
        ./modules/access-shared-drive.nix
        ./modules/vscode.nix
        ./modules/wasmcloud.nix
        {
          services.xserver = {
            enable = true;
            displayManager.lightdm.enable = true;
            xkb.layout = "us";
          };
        }
      ];

      mkHost =
        {
          system,
          hostName,
          isDesktop ? false,
          useHomeManager ? false,
          useVSCodeServer ? false,
          extraModules ? [ ],
        }:
        let
          pkgs = pkgsForSystem system;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs isDesktop; };
          modules =
            baseModules
            ++ (if isDesktop then desktopModules else [ ])
            ++ (if useHomeManager then [ inputs.home-manager.nixosModules.home-manager ] else [ ])
            ++ (if useVSCodeServer then [ inputs.nixos-vscode-server.nixosModules.default ] else [ ])
            ++ extraModules
            ++ [
              {
                networking.hostName = hostName;
                time.timeZone = "America/Toronto";

                # Set Zsh as the default shell for all users and root
                users.defaultUserShell = pkgs.zsh;
                users.users.root.shell = pkgs.zsh;

                systemd.tmpfiles.rules = [
                  "d /home/jaykchen/.config 0700 jaykchen users"
                  "d /home/jaykchen/.cache 0700 jaykchen users"
                  "d /home/jaykchen/.local/state 0700 jaykchen users"
                ];

                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  extraSpecialArgs = {
                    inherit inputs isDesktop;
                  };
                  users.jaykchen =
                    if useHomeManager then
                      { pkgs, ... }:
                      {
                        imports = [ ./home.nix ];
                        home.stateVersion = "24.11";
                        programs.zsh.enable = true;
                        home.packages = with pkgs; [
                          fzf
                          starship
                        ];
                      }
                    else
                      null;
                };
              }
            ];
        };
    in
    {
      nixosConfigurations = {
        pn53 = mkHost {
          system = "x86_64-linux";
          hostName = "pn53";
          isDesktop = false;
          useHomeManager = true; # Cloud host: no Home Manager or VSCode Server
          useVSCodeServer = false;
          extraModules = [ ./modules/hardware-configuration-pn53.nix ];
        };

        nr200 = mkHost {
          system = "x86_64-linux";
          hostName = "nr200";
          isDesktop = true;
          useHomeManager = true; # Desktop: includes Home Manager and VSCode Server
          useVSCodeServer = true;
          extraModules = [ ./modules/hardware-configuration-nr200.nix ];
        };

        md16 = mkHost {
          system = "x86_64-linux";
          hostName = "md16";
          isDesktop = true;
          useHomeManager = true; # Desktop: includes Home Manager and VSCode Server
          useVSCodeServer = true;
          extraModules = [
            ./modules/hardware-configuration-md16.nix
            ./modules/intel-gpu.nix
          ];
        };

        b550 = mkHost {
          system = "x86_64-linux";
          hostName = "b550";
          isDesktop = true;
          useHomeManager = true; # Desktop: includes Home Manager and VSCode Server
          useVSCodeServer = true;
          extraModules = [
            ./modules/hardware-configuration-b550.nix
            { networking.domainName = "localdomain"; }
          ];
        };

        cloud1 = mkHost {
          system = "x86_64-linux";
          hostName = "cloud1";
          isDesktop = false;
          useHomeManager = false; # Cloud host: no Home Manager or VSCode Server
          useVSCodeServer = false;
          extraModules = [
            ./modules/hardware-configuration-sg.nix
            { zramSwap.enable = true; }
          ];
        };
      };
    };
}

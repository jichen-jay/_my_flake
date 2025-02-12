{
  description = "NixOS configuration with flakes, optimized for fish, Home Manager, and VSCode Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    flake-utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
    niri.url = "github:sodiboo/niri-flake";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixos-vscode-server,
      flake-utils,
      impermanence,
      niri,
      ...
    }:
    let
      pkgsForSystem = system: import nixpkgs { inherit system; };

      baseModules = [
        impermanence.nixosModules.impermanence
        ./modules/users.nix
        ./modules/base.nix
        ./modules/ssh.nix
        # ./modules/podman.nix
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];

      desktopModules = [
        ./modules/niri-mod.nix
        # ./modules/xfce.nix
        ./modules/printer.nix
        ./modules/font.nix
        ./modules/net-tools.nix
        # ./modules/desktop-entry.nix
        # ./modules/access-shared-drive.nix
        ./modules/vscode.nix
        ./modules/wasmcloud.nix
        {
          services.xserver = {
            xkb.layout = "us";
          };
        }
      ];

      mkHost =
        {
          system,
          hostName,
          isDesktop ? false,
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
            ++ (if useVSCodeServer then [ inputs.nixos-vscode-server.nixosModules.default ] else [ ])
            ++ extraModules
            ++ [
              {
                networking = {
                  hostName = hostName;
                  networkmanager.enable = true;
                  firewall.allowedTCPPorts = [
                    22
                    8000
                    8080
                  ];
                };

                time.timeZone = "America/Toronto";
                users.defaultUserShell = pkgs.fish;
                users.users.root.shell = pkgs.fish;

                systemd.tmpfiles.rules = [
                  "d /home/jaykchen/.config 0700 jaykchen users"
                  "d /home/jaykchen/.cache 0700 jaykchen users"
                  "d /home/jaykchen/.local/state 0700 jaykchen users"
                ];

                environment.systemPackages = with pkgs; [
                  fzf
                  starship
                  direnv
                ];
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
          useVSCodeServer = false;
          extraModules = [ ./modules/hardware-configuration-pn53.nix ];
        };

        nr200 = mkHost {
          system = "x86_64-linux";
          hostName = "nr200";
          isDesktop = true;
          useVSCodeServer = true;
          extraModules = [
            ./modules/hardware-configuration-nr200.nix
            {
              nixpkgs.overlays = [
                (self: super: {
                  stdenv = super.stdenv // {
                    ccFlags = "-march=znver3 -O2"; # Zen 3-specific compiler flags
                  };
                })
              ];
            }
            {
              programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
              };
            }
          ];
        };

        md16 = mkHost {
          system = "x86_64-linux";
          hostName = "md16";
          isDesktop = true;
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
          useVSCodeServer = false;
          extraModules = [
            ./modules/hardware-configuration-sg.nix
            { zramSwap.enable = true; }
          ];
        };
      };
    };
}

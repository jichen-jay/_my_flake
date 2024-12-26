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
                      imports = [ ./home.nix ];
                      programs.zsh = {
                        enable = true;
                        oh-my-zsh = {
                          enable = true;
                          theme = "powerlevel10k/powerlevel10k";
                          plugins = [
                            "git"
                            "direnv"
                          ];
                        };
                        initExtra = ''
                          # Enable Powerlevel10k instant prompt for faster startup
                          if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh" ]]; then
                            source "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh"
                          fi

                          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
                          source ${pkgs.fzf}/share/fzf/completion.zsh
                          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

                          # Core Settings
                          typeset -g POWERLEVEL9K_MODE=nerdfont-complete
                          typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
                          typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
                          POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

                          # Directory Display
                          typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
                          typeset -g POWERLEVEL9K_DIR_FOREGROUND=0
                          typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
                          typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

                          # Simplified VCS
                          typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2
                          typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=3

                          # Time Format
                          typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"

                          # Minimal Left Prompt Elements
                          typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
                            dir
                            vcs
                          )

                          # Minimal Right Prompt Elements
                          typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
                            time
                          )
                        '';
                        plugins = [
                          {
                            name = "zsh-autosuggestions";
                            src = pkgs.zsh-autosuggestions;
                          }
                          {
                            name = "zsh-syntax-highlighting";
                            src = pkgs.zsh-syntax-highlighting;
                          }
                          {
                            name = "powerlevel10k";
                            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
                            file = "powerlevel10k.zsh-theme";
                          }
                          {
                            name = "zsh-fzf-history-search";
                            src = pkgs.zsh-fzf-history-search;
                          }
                        ];
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

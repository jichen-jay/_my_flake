{
  config,
  inputs,
  pkgs,
  ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];

  environment = {
    shells = with pkgs; [ zsh ];

    systemPackages = with pkgs; [
      (ripgrep.override {
        stdenv = pkgs.stdenv // {
          mkDerivation =
            args:
            pkgs.stdenv.mkDerivation (
              args
              // {
                NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") + " -march=native -O3";
              }
            );
        };
      })
      (zsh.override {
        stdenv = pkgs.stdenv // {
          mkDerivation =
            args:
            pkgs.stdenv.mkDerivation (
              args
              // {
                NIX_CFLAGS_COMPILE = "${toString (args.NIX_CFLAGS_COMPILE or "")} -march=native -O3";
              }
            );
        };
      })
      pass
      gnupg
      pinentry
      git
      btop
      tmux
      tree
      wget
      curl
      fzf
      zsh-syntax-highlighting
      zsh-fzf-history-search
      zsh-completions
      zsh-autosuggestions
      lunarvim
      nil
      nixpkgs-fmt
      bat
      jq
      file
      tokei
      gcc-unwrapped
      pkgs.starship
    ];

    shellAliases = {
      ll = "ls -l";
      ci = "git commit";
      co = "git checkout";
      st = "git status";
      lg = "git log";
      gs = "git log -S";
    };

    sessionVariables = {
      EDITOR = "vim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      LANG = "en_US.UTF-8";
    };
  };

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
    gc = {
      automatic = true;
    };
  };

  system.stateVersion = "24.11";

  security.sudo.enable = true;

  programs.tmux.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellInit = ''
      export LANG=en_US.UTF-8
    '';

    interactiveShellInit = ''
      eval "$(direnv hook zsh)"

      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

      # Enable fzf keybindings and completions
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Autosuggestion navigation setup for zsh-autosuggestions plugin
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(forward-word backward-word)

    '';

    promptInit = ''
      # Initialize starship prompt for zsh users
      # eval "$(starship init zsh)"

     eval "$(/run/current-system/sw/bin/starship init zsh)" 
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = false;
      };
      git_branch = {
        symbol = "🌱 ";
        truncation_length = 4;
        truncation_symbol = "";
      };
      git_commit = {
        commit_hash_length = 4;
        tag_symbol = "🔖 ";
      };
      git_state = {
        format = "($state($progress_current of $progress_total)) ";
        cherry_pick = "[🍒 PICKING](bold red)";
      };
      git_status = {
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "++($count)";
        renamed = "👅";
        deleted = "🗑";
      };
    };
  };
}

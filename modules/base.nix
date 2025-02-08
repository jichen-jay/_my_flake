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
    ];

    shellAliases = {
      ll = "ls -l";
      ci = "git commit";
      co = "git checkout";
      st = "git status";
      lg = "git log";
      gs = "git log -S";
      dls = "sudo docker image ls";
      dps = "sudo docker ps -a";
      dcm = "sudo docker commit";
      dri = "sudo docker run --rm -it";
      dpl = "sudo docker pull";
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
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "24.11";

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse off
    '';
    plugins = with pkgs.tmuxPlugins; [
      yank
      resurrect
      continuum
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellInit = ''
      # Base shell initialization
      export LANG=en_US.UTF-8
    '';

    interactiveShellInit = ''
      eval "$(direnv hook zsh)"
      export PATH="/run/current-system/sw/bin:$PATH"
      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
      export FZF_CTRL_R_OPTS="--sort --exact"

      # Enable fzf keybindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # fzf-tab configuration
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags '--height=40% --layout=reverse --border --info=inline'
      zstyle ':fzf-tab:*' continuous-trigger 'tab'

      bindkey "^[[1;3C" forward-word
      bindkey '^[[1;3D' backward-word               # Alt + Left
      bindkey '^[[1;5C' forward-word                # Ctrl + Right
      bindkey '^[[1;5D' backward-word               # Ctrl + Left

      # Enable autosuggestion navigation
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(forward-word backward-word)
      ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-word)

      zle_highlight=(paste:none)
    '';

    promptInit = ''
      # eval "$(${pkgs.starship}/bin/starship init zsh)"
      eval "$(starship init zsh)"
      autoload -U promptinit
      promptinit
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
        format = "[($state($progress_current of $progress_total))]($style) ";
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
        staged = "[++($count)](green)";
        renamed = "👅";
        deleted = "🗑";
      };
    };
  };
}

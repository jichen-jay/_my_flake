{ pkgs, config, ... }:
{
  xdg.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    initExtra = ''
      eval "$(direnv hook zsh)"

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
      bindkey "^[[1;3D" backward-word
      zle_highlight=(paste:none)

      # Aliases
      alias ll="ls -l"
      alias ci="git commit"
      alias co="git checkout"
      alias st="git status"
      alias lg="git log"
      alias gs="git log -S"
      alias dls="sudo docker image ls"
      alias dps="sudo docker ps -a"
      alias dcm="sudo docker commit"
      alias dri="sudo docker run --rm -it"
      alias dpl="sudo docker pull"
    '';

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-fzf-history-search";
        src = pkgs.zsh-fzf-history-search;
      }
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "master";
          hash = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Starship settings remain unchanged
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

  home.packages = with pkgs; [
    fzf
    starship
  ];
}

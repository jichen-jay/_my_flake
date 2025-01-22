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

      # zsh-autocomplete configuration
      zstyle ':autocomplete:*' min-input 1
      zstyle ':autocomplete:*' insert-unambiguous yes
      zstyle ':autocomplete:*' widget-style menu-select

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
        name = "zsh-autocomplete";
        src = pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = "main";
          sha256 = "sha256-o8IQszQ4/PLX1FlUvJpowR2Tev59N8lI20VymZ+Hp4w=";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

  home.packages = with pkgs; [
    fzf
    starship
  ];
}

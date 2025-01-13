{ pkgs, config, ... }:
{
  xdg.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Add history configuration
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    initExtra = ''
      eval "$(direnv hook zsh)"
            
      # Initialize Pure prompt
      fpath+=${pkgs.pure-prompt}/share/zsh/site-functions
      autoload -U promptinit
      promptinit

      # Pure prompt customization
      PURE_CMD_MAX_EXEC_TIME=10

      # Set max directory length
      PURE_TRUNCATE_DIR_LENGTH=4  # Shows only current directory

      # Color customization
      zstyle :prompt:pure:path color '#00ff00'  # Bright green for path
      zstyle :prompt:pure:git:branch color '#ffff00'  # Yellow for git branch
      zstyle :prompt:pure:prompt:success color '#00ff00' 
      # zstyle :prompt:pure:git:branch color 242
      zstyle :prompt:pure:git:dirty color 218
      zstyle :prompt:pure:git:arrow color cyan
      zstyle :prompt:pure:git:stash color cyan
      # zstyle :prompt:pure:prompt:success color magenta
      zstyle :prompt:pure:prompt:error color red
      zstyle :prompt:pure:execution_time color yellow
      zstyle :prompt:pure:git:action color 242
      zstyle :prompt:pure:user color 242
      zstyle :prompt:pure:host color 242
      zstyle :prompt:pure:virtualenv color 242

      # Enable git stash status
      zstyle :prompt:pure:git:stash show yes

      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word
      # unset zle_bracketed_paste
      zle_highlight=(paste:none)

      # Aliases from bash.shellAliases in home.nix
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

      prompt pure
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
    ];
  };

  home.packages = with pkgs; [
    fzf
    pure-prompt
  ];
}

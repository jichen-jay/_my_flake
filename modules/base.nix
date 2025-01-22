# ./modules/base.nix
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # System-wide ZSH plugins
  environment.pathsToLink = [ "/share/zsh" ];
  environment = {
    systemPackages = with pkgs; [
      pass
      gnupg
      fzf
      starship
      zsh
      zsh-syntax-highlighting
      zsh-fzf-history-search
    ];

    # System-wide shell aliases
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
  };

  system.stateVersion = "24.11";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    interactiveShellInit = ''
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
    '';

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
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

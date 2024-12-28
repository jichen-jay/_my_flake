{ pkgs, config, ... }:
{
  xdg.enable = true;

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

    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    # Add history configuration
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    initExtra = ''
      source ${./modules/p10k-lean.zsh}
      eval "$(direnv hook zsh)"
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
    zsh-powerlevel10k
  ];
}

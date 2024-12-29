{ pkgs, config, ... }:
{
  xdg.enable = true;

  programs.zsh = {
    enable = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [
    #     "git"
    #     "direnv"
    #   ];
    # };

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
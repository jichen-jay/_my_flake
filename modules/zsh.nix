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
      # Enable Powerlevel10k instant prompt
      if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh" ]]; then
        source "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh"
      fi

      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Core Settings
      typeset -g POWERLEVEL9K_MODE="unicode-in-256colors"
      typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
      typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

      # Frame Settings
      # typeset -g POWERLEVEL9K_LEFT_PROMPT_FRAME=true
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_FRAME=true
      typeset -g POWERLEVEL9K_FRAME_COLOR=238

      # Path and Prompt Styling
      typeset -g POWERLEVEL9K_HOST_BACKGROUND="none"
      typeset -g POWERLEVEL9K_DIR_BACKGROUND="none"
      typeset -g POWERLEVEL9K_DIR_FOREGROUND=31  # Blue color for path
      typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND="none"
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=76
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=196

      # Theme Adaptation
      typeset -g POWERLEVEL9K_COLOR_SCHEME="light"
      typeset -g POWERLEVEL9K_COLORS_LEVEL="256"
      typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=' '

      # Remove background colors from segments
      typeset -g POWERLEVEL9K_VCS_BACKGROUND="none"
      typeset -g POWERLEVEL9K_STATUS_BACKGROUND="none"
      typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND="none"
      typeset -g POWERLEVEL9K_NODEENV_BACKGROUND="none"
      typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND="none"
      typeset -g POWERLEVEL9K_AWS_BACKGROUND="none"
      typeset -g POWERLEVEL9K_RAM_BACKGROUND="none"
      typeset -g POWERLEVEL9K_SWAP_BACKGROUND="none"
      typeset -g POWERLEVEL9K_IP_BACKGROUND="none"
      typeset -g POWERLEVEL9K_VPN_IP_BACKGROUND="none"
      typeset -g POWERLEVEL9K_WIFI_BACKGROUND="none"
      typeset -g POWERLEVEL9K_BATTERY_BACKGROUND="none"

      # Auto Theme Detection
      typeset -g POWERLEVEL9K_COLOR_SCHEME="auto"
      typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
      typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=' '

      # Visual Style
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR="·"
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=238
      typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_CHAR="·"
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_GAP_CHAR="·"

      # Icon Settings
      typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=""
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON="?"
      typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON="!"
      typeset -g POWERLEVEL9K_VCS_STAGED_ICON="+"

      # Remove Time Display
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status
        virtualenv
        nodeenv
        kubecontext
        ram
        swap
        public_ip
        vpn_ip
        wifi
      )

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

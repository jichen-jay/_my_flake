{ pkgs, config, ... }: {
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
      # Enable Powerlevel10k instant prompt
      if [[ -r "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh" ]]; then
        source "${config.xdg.cacheHome}/p10k-instant-prompt-${config.home.username}.zsh"
      fi

      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Core Settings
      typeset -g POWERLEVEL9K_MODE=nerdfont-complete
      typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
      typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

      # Directory Display
      typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
      typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

      # VCS Colors (Git)
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=076
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=214

      # Time Display
      typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
      typeset -g POWERLEVEL9K_TIME_FOREGROUND=246

      # Battery Settings
      typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
      typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=160
      typeset -g POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND=70
      typeset -g POWERLEVEL9K_BATTERY_STAGES='\UF008E\UF007A\UF007B\UF007C\UF007D\UF007E\UF007F\UF0080\UF0081\UF0082\UF0079'

      # Environment Colors
      typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=37
      typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
      typeset -g POWERLEVEL9K_RUBY_VERSION_FOREGROUND=168
      typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=134
      typeset -g POWERLEVEL9K_AWS_FOREGROUND=208

      # System Monitoring Colors
      typeset -g POWERLEVEL9K_RAM_FOREGROUND=66
      typeset -g POWERLEVEL9K_SWAP_FOREGROUND=96
      typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND=94
      typeset -g POWERLEVEL9K_WIFI_FOREGROUND=68

      # Load Indicators
      typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=66
      typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=178
      typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=166

      # Disk Usage Settings
      typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
      typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95

      # Left and Right Prompt Elements
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        context
        dir
        vcs
      )

      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status
        virtualenv
        nodeenv
        kubecontext
        aws
        ram
        swap
        public_ip
        vpn_ip
        wifi
        battery
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
}

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  staticCurl = pkgs.stdenv.mkDerivation {
    pname = "curl-static-h3";
    version = "8.12.0";
    src = pkgs.fetchurl {
      url = "https://github.com/stunnel/static-curl/releases/download/8.12.0/curl-linux-x86_64-musl-8.12.0.tar.xz";
      sha256 = "1wj9g4yapyhy4073pg0wxh728smasl7sbapmj79jjq1b1c24j262";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p tmpdir
      cd tmpdir
      tar xf $src
      mkdir -p $out/bin
      cp curl $out/bin/curl-static
      chmod +x $out/bin/curl-static
      cp trurl $out/bin/trurl
      chmod +x $out/bin/trurl
    '';
  };
in

{
  environment.pathsToLink = [ "/share/fish" ];

  environment = {
    shells = with pkgs; [ fish ];

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
      (fish.override {
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
      staticCurl
      curl
      fzf
      fishPlugins.foreign-env
      fishPlugins.fzf
      kitty
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
      cs = "curl-static";
      ll = "ls -l";
      ci = "git commit";
      co = "git checkout";
      st = "git status";
      lg = "git log";
      gs = "git log -S";
      hs = "hyprshot -m region -m active --clipboard-only";
      hw = "hyprshot -m window -m active --clipboard-only";
    };

    sessionVariables = {
      EDITOR = "vim";
      SHELL = "${pkgs.fish}/bin/fish";
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
  programs.fish = {
    enable = true;
    vendor = {
      config.enable = true;
      completions.enable = true;
      functions.enable = true;
    };

    # Remove the plugins section as it's not a valid option
    # Instead, install plugins through systemPackages

    interactiveShellInit = ''
      # Set up direnv
      direnv hook fish | source

      # FZF configuration
      set -x FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --info=inline"

      # Fish key bindings
      bind \e\[1\;5C forward-word
      bind \e\[1\;5D backward-word

      # Initialize starship prompt
      starship init fish | source
    '';
  };

  environment.etc."xdg/kitty/kitty.conf".text = ''
    shell ${pkgs.fish}/bin/fish
    shell_integration enabled
    font_size 12.0
    enable_audio_bell no
    scrollback_lines 10000
    copy_on_select clipboard

    # Keybindings
    map ctrl+right send_text all \x1b[1;5C
    map ctrl+left send_text all \x1b[1;5D
  '';

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

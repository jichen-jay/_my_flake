{ config, pkgs, ... }: {
  # Nix settings
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto"; # Safe CPU utilization
    trusted-users = [ "root" "@wheel" ];
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";

  imports = [
    ./hardware-configuration.nix
  ];

  # Timezone and Locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # NixOS Version (stateVersion)
  system.stateVersion = "24.11";

  # System Packages
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    google-chrome
    vscode
    postman
    wget
    tree
    curl
    git
    tmux
    grpcurl
    podman
    steam-run
    btop
    cmake
    # gcc_multi
    file
    xclip
    font-manager
    jetbrains-mono
    vistafonts-chs
    # to build llama
    gnumake # Unix Makefiles build system
    ninja # Alternative build system
    gcc # Ensure base gcc is installed
    binutils # Required build tools
    xdg-utils
  ];

  # Fonts Configuration
  fonts.packages = with pkgs; [
    jetbrains-mono
    vistafonts-chs
  ];

  # Shell Aliases
  programs.bash.shellAliases = {
    ll = "ls -l";
    ci = "git commit";
    co = "git checkout";
    st = "git status";
    lg = "git log";
    gs = "git log -S";
  };

  # Git Configuration
  environment.etc."gitconfig".text = ''
    [user]
      name = "jaykchen@icloud.com"
      email = "jaykchen@icloud.com"
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # SSH Configuration
  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ~/.ssh/id_ed25519
      User git
  '';
}

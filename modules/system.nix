{ config, pkgs, ... }: {
  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    gcc_multi
    file
    xclip
    font-manager
    jetbrains-mono
    vistafonts-chs
    hello
  ];

  # Fonts Configuration
  fonts.fonts = with pkgs; [
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

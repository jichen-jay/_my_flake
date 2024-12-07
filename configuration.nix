{ config, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };


  imports = [
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
      ./hardware-configuration.nix
    ];

  services.vscode-server.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

 services.gnome.gnome-keyring.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jaykchen = {
    isNormalUser = true;
    description = "jaykchen";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
services.displayManager.autoLogin.enable = true;
services.displayManager.autoLogin.user = "jaykchen";

  # Install firefox.
  programs.firefox.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse off
  '';
    plugins = with pkgs.tmuxPlugins; [
      yank
      resurrect
      continuum
    ];
  };
  
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    google-chrome
    wget
    file
    vscode
    dive
    curl
    git
    tree
    xclip
    tmux
    grpcurl
    podman
    postman
    steam-run
    btop
    cmake
    gcc_multi
    font-manager
    jetbrains-mono
    vistafonts-chs
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    vistafonts-chs  
  ];

  environment.shellAliases = {
    ll = "ls -l";
  };

  nix.settings.experimental-features = "nix-command flakes";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  environment.etc."gitconfig" = {
    text = ''
      [user]
        name = "jaykchen@icloud.com"
        email = "jaykchen@icloud.com"
    '';
  };

programs.bash.shellAliases = {
  ci = "git commit";
  co = "git checkout";
  st = "git status";
  lg = "git log";
  gs = "git log -S";
};

programs.git = {
  enable = true;
  lfs.enable = true;
};

programs.ssh = {
  extraConfig = ''
    Host github.com
      IdentityFile ~/.ssh/id_ed25519
      User git
  '';
};


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.authorizedKeysFiles = [ "~/.ssh/authorized_keys" ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8000 8080  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

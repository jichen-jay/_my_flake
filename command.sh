sudo nixos-rebuild switch --flake .#nixos


//need to use env to compile:
export NIXPKGS_ALLOW_UNFREE=1
sudo -E nixos-rebuild switch --flake .#pn53 --impure


//Create the directory structure with proper ownership:
sudo mkdir -p /run/jaykchen/1000/containers
sudo chown -R jaykchen:users /run/jaykchen/1000
sudo chmod -R 700 /run/jaykchen/1000

//Ensure the parent directory has correct permissions:
sudo chown jaykchen:users /run/jaykchen
sudo chmod 700 /run/jaykchen


# Clean shell configs
rm -f ~/.zshenv ~/.zshrc ~/.p10k.zsh
rm -f ~/.xsession-errors{,.old} ~/.Xauthority

rm -f ~/.config/Code/User/settings.json{,.bkp,.backup}

# Clean up home-manager related files
rm -rf /home/jaykchen/.config

rm -rf ~/.config/{home-manager,nixpkgs}
rm -rf ~/.local/share/home-manager
rm -rf ~/.cache/home-manager
rm -rf ~/.nix-profile
rm -rf ~/.local/state/{home-manager,nix}

sudo rm -rf ~/.local/share/containers
rm -rf ~/.config/containers
sudo rm -rf /run/user/1001/{containers,libpod}


rm -rf ~/.config/systemd/user/*
systemctl --user daemon-reload

rm -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml


systemctl --user reset-failed
systemctl --user daemon-reload

#audio
rm -rf ~/.config/pulse/
rm -rf ~/.pulse*



podman run \
       --rm \
       -it \
       --volume "/nix/store:/nix/store:ro" \
       --mount=type=tmpfs,tmpfs-size=512M,destination=/run \
       --mount=type=tmpfs,tmpfs-size=512M,destination=/run/wrappers \
       --systemd=always \
       --env container=podman \
       --rootfs root:O \
       $(readlink result)/init
is a less hacky way to setup the wrapppers directory, instead of using postBootCommands, and it also doesn’t cause the problems I reported above on 24.11 and unstable.


podman run -d \                     
  --name redis \
  -p 127.0.0.1:6379:6379 \
  --security-opt label=disable \
  -v redis-data:/data \
  redis:latest redis-server --bind 0.0.0.0



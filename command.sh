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


sudo umount /home/jaykchen/.config/
sudo umount /home/jaykchen/.config/google-chrome
sudo umount /home/jaykchen/.config/Postman

rm -rf ~/.config



sudo rm -rf ~/.config/git
sudo rm -rf ~/.config/systemd
sudo rm -rf ~/.config/environment.d
sudo rm -rf ~/.config/direnv
sudo rm -rf ~/.config/fontconfig

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



mkdir -p ~/chrome-backup
cp ~/.config/google-chrome/'Local State' ~/chrome-backup/
cp -r ~/.config/google-chrome/Default ~/chrome-backup/

mkdir -p ~/.config/google-chrome
cp ~/chrome-backup/'Local State' ~/.config/google-chrome/
cp -r ~/chrome-backup/Default ~/.config/google-chrome/


mkdir -p ~/postman-backup

cp -r ~/.config/Postman/Postman_Config ~/postman-backup/
cp -r ~/.config/Postman/storage ~/postman-backup/
cp -r ~/.config/Postman/proxy ~/postman-backup/
cp -r ~/.config/Postman/Partitions ~/postman-backup/

chmod -R 700 ~/postman-backup
chown -R jaykchen:users ~/postman-backup


//nix on ubuntu
nix-env -iA nixpkgs.nixos-rebuild
experimental-features = nix-command flakes

nix run home-manager/release-24.11 -- switch --flake .#jaykchen@b550


nix profile install nixpkgs#lunarvim
rm -rf ~/.local/share/lunarvim\nrm -rf ~/.config/lvim\n
mkdir -p ~/.config/lvim\n
lvim _my_flake
 pgrep -l nvim
 pkill -9 nvim


sudo NIX_SSHOPTS="-i /home/jaykchen/.ssh/nixos_ed25519" \
  nixos-rebuild switch \
  --use-remote-sudo \
  --target-host jaykchen@10.0.0.93 \
  --build-host jaykchen@10.0.0.93 \
  --flake .#pn53

sudo NIX_SSHOPTS="-i /home/jaykchen/.ssh/pn53_id_rsa" \
  nixos-rebuild switch \
  --use-remote-sudo \
  --target-host jaykchen@10.0.0.40 \
  --build-host jaykchen@10.0.0.40 \
  --flake .#md16


nix build .#nixosConfigurations.jaykchen.config.system.build.toplevel \
  --store 'ssh://jaykchen@10.0.0.93?remote-store=local?root=/' --flake .#pn53


nix build .#nixosConfigurations.pn53.config.system.build.toplevel --store 'ssh://jaykchen@10.0.0.93?remote-store=local?root=/' --flake .#pn53


NIX_SSHOPTS="-i /home/jaykchen/.ssh/nixos_ed25519 -o StrictHostKeyChecking=accept-new" \
  nix build ".#nixosConfigurations.pn53.config.system.build.toplevel" \
  --store "ssh-ng://root@10.0.0.93?remote-store=local?root=/"


sudo nixos-rebuild switch  --flake .#nr200 --option system-features gccarch-znver3


➜ journalctl -b -1 | grep -E "panic|oops|fatal|error"
Feb 08 11:15:00 nr200 mount[5406]: mount: /nix/store/ggzlqjb390v22ryclzjh267pn7hwpr6h-bash_profile: wrong fs type, bad option, bad superblock on /nix/persist/home/jaykchen/.bash_profile, missing codepage or helper program, or other error.
Feb 08 11:15:00 nr200 pipewire[1818]: mod.x11-bell: X11 I/O error handler called on display :0
Feb 08 11:15:00 nr200 pipewire[1818]: mod.x11-bell: X11 display (:0) has encountered a fatal I/O error


xfce4-panel --quit
pkill xfconfd
rm -rf ~/.config/xfce4/panel ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
xfce4-panel

mv ~/.cache/sessions

chown root:root /run/current-system/sw/bin/sudo
chmod 4755 /run/current-system/sw/bin/sudo

grep -R "hm-session-vars.sh" ~/.zshrc ~/.config

rm -rf ~/.config/google-chrome/Default/GPUCache/

google-chrome-stable --disable-gpu --ozone-platform=wayland --crashpad-database=$HOME/.config/google-chrome/Crashpad


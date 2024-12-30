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

rm -f ~/.config/Code/User/settings.json{,.bkp,.backup}

rm -f ~/.xsession-errors{,.old} ~/.Xauthority

rm -rf ~/.config/{home-manager,nixpkgs} ~/.local/share/home-manager ~/.cache/home-manager

rm -rf ~/.nix-profile
rm -rf ~/.local/share/home-manager
rm /home/jaykchen/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml


#container 
rm -rf ~/.local/share/containers


#audio
rm -rf ~/.config/pulse/*
rm -rf ~/.pulse*


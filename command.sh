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
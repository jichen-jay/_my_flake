sudo nixos-rebuild switch --flake .#nixos


//need to use env to compile:
export NIXPKGS_ALLOW_UNFREE=1
sudo -E nixos-rebuild switch --flake .#pn53 --impure

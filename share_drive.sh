//server side
sudo apt install nfs-kernel-server nfs-common rpcbind

sudo mkdir -p /var/nfs/public
sudo chown nobody:nogroup /var/nfs/public
sudo chmod 777 /var/nfs/public

/etc/exports
/var/nfs/public 10.0.0.0/24(rw,sync,no_root_squash,no_subtree_check)

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

sudo mount server_ip:/var/nfs/public /mnt/nfs-public/

# permanent mounting, add to /etc/fstab:
server_ip:/var/nfs/public /mnt/nfs-public nfs rw 0 0


//client side
sudo apt update
sudo apt install rpcbind nfs-common

sudo mkdir /mnt/nfs_share

sudo mount server_ip:/shared/directory /mnt/nfs_share

//permanent mounting, add this line to /etc/fstab:
server_ip:/shared/directory /mnt/nfs_share nfs rw,sync 0 0


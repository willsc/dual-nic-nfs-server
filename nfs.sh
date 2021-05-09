#!/bin/bash  -x 


fdisk -l


sudo parted -s -a optimal /dev/sdb mklabel gpt
sudo echo "y" |mkfs -t ext4   /dev/sdb


fstab=/etc/fstab

if [[ $(grep -q "sdb" "$fstab") ]]
then
    sudo oecho "#nfs-disc" >> /etc/fstab
    sudo echo "/dev/sdb /mnt/nfs_share ext4 defaults 0 2" >> /etc/fstab
else
    echo "Entry in fstab exists."
fi


sudo mkdir -p /mnt/nfs_share
sudo mount /dev/sdb /mnt/nfs_share




apt update
apt install -y nfs-kernel-server
mkdir -p /mnt/nfs_share
chmod 777 /mnt/nfs_share/
echo "/mnt/nfs_share   *(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -a
systemctl restart nfs-kernel-server

virsh destroy $1
sleep 5
virsh undefine $1
sleep 5
#virt-install --name $1 --os-variant=rhel7 --description $1 --ram=15048 --vcpus=2 --disk path=/var/lib/libvirt/images/$1.img,size=60,sparse --network bridge:br0 
virt-clone --connect qemu:///system --original rhel75 --name $1 --file /var/lib/libvirt/images/$1.img --mac $2


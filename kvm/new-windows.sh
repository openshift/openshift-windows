virsh destroy $1
sleep 5
virsh undefine $1
sleep 5
virt-clone --connect qemu:///system --original win1709 --name $1 --file /var/lib/libvirt/images/$1.img --mac $2 


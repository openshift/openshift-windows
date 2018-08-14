virsh destroy rhel75
sleep 5
virsh undefine rhel75
sleep 5
virt-install --name rhel75 --os-variant=rhel7 --description "rhel75" --ram=15048 --vcpus=2 --disk path=/var/lib/libvirt/images/openshift.img,size=60,sparse --network bridge:br0 --cdrom=/var/lib/libvirt/images/rhel75.iso 


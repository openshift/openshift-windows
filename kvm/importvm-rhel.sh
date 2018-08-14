virt-install --name rhel75 --os-variant=rhel7 --cpu host --description "rhel75" --ram=15048 --vcpus=2 --disk path=/var/lib/libvirt/images/rhel75.img,size=60,sparse --network bridge:br0 --import


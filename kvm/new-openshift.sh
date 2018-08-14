rm -f /var/lib/libvirt/images/openshift.img
./new-linux.sh openshift 00:0c:29:f8:21:21
virsh start openshift


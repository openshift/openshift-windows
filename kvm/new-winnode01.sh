rm -f /var/lib/libvirt/images/winnode01.img
./new-windows.sh winnode01 00:0c:29:f8:22:22
virsh start winnode01


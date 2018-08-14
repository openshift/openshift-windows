# kvm tools for testing openshift-windows
## Packet.net setup
Create a new c2.medium.x86 instance and choose centos7. During the create dialog, make sure to increase the number of ip's by going to the ssh-and-user-data tab
and choose /28 subnet

## KVM Setup on Centos 7
This is designed for use on Packet.Net EpyC Hardware as a service
  yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer bridge-utils
  yum install -y  "@X Window System" xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils -y
  yum install -y dhcp

Execute:
systemctl start libvirtd
systemctl enable libvirtd
rmmod kvm-amd
cp etc/modprobe.d/dist.conf /etc/modprobe.d/
modprobe kvm-amd

To verify nested virt is enable:
cat /sys/module/kvm_amd/parameters/nested

virt-manager
Right click on the qemu/kvm and delete the default network

## Setup the bonded bridge
Edit the bond0 ifcfg
 /etc/sysconfig/network-scripts/ifcfg-bond0  (Example in:  etc/sysconfig/network-scripts/ifcfg-bond0)

Add the Bridge
brctl addif br0 bond0
brctl show

Example:
[root@kvm kvm]# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.ec0d9abf3d58	no		bond0
							vnet0

## Setup dhcp
Add dhcp support to host for packet.net range
Example: etc/dhcp/dhcpd.conf


## Verify nested virt in guest vm
ssh into guest vm, and use lsmod, and lscpu to verify nested virt

[root@kvm kvm]# ssh root@openshift.ncc9.com
The authenticity of host 'openshift.ncc9.com (147.75.109.147)' can't be established.
ECDSA key fingerprint is SHA256:OcqRfBiWK1OncHR6DTDiBDSvLmlUfnwlUkH0UNFuOyc.
ECDSA key fingerprint is MD5:18:4a:ef:05:71:75:42:40:f3:ff:9e:c5:cb:b5:6c:ef.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'openshift.ncc9.com' (ECDSA) to the list of known hosts.
root@openshift.ncc9.com's password: 
Last failed login: Fri Aug  3 18:33:30 EDT 2018 from 103.89.89.189 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Fri Aug  3 17:49:24 2018 from 75-139-7-79.dhcp.kgpt.tn.charter.com
[root@openshift ~]# hostname
openshift.ncc9.com
[root@openshift ~]# lsmod | grep kvm
kvm_amd              2176426  0 
kvm                   578518  1 kvm_amd
irqbypass              13503  1 kvm
[root@openshift ~]# lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                2
On-line CPU(s) list:   0,1
Thread(s) per core:    1
Core(s) per socket:    1
Socket(s):             2
NUMA node(s):          1
Vendor ID:             AuthenticAMD
CPU family:            23
Model:                 1
Model name:            AMD EPYC Processor (with IBPB)
Stepping:              2
CPU MHz:               1996.249
BogoMIPS:              3992.49
Virtualization:        AMD-V
Hypervisor vendor:     KVM
Virtualization type:   full
L1d cache:             64K
L1i cache:             64K
L2 cache:              512K
NUMA node0 CPU(s):     0,1
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt pdpe1gb lm art rep_good nopl extd_apicid eagerfpu pni pclmulqdq ssse3 fma cx16 sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm cmp_legacy svm cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw retpoline_amd vmmcall fsgsbase bmi1 avx2 smep bmi2 rdseed adx smap clflushopt sha_ni xsaveopt xsavec xgetbv1 ibpb arat
[root@openshift ~]# 


## Adding VirtIO Drivers
virsh change-media  win1709 hda /usr/share/virtio-win/virtio-win-0.1.149.iso


## Scripts

### restore-image.sh
This allows the restore of a saved kvm image via azure using azcopy. Install azcopy first, before using the scripts.
The blob acct must be set to restore the image

[root@kvm kvm]# echo $BLOB_ACCT
hybridkvm.blob.core.windows.net

### initialvm.sh - Use o rhel75 iso to install a rhel 75 image
This script takes a rhel75 iso image of the complete os and creates a thin vm. Once its created, a subscription needs to be added, and any extranious rhn repos removed.
It should be set up to use dhcp.

## Improving Perfomance
Using virtio drivers will significantly improve perofmance in a kvm environment:

wget https://fedorapeople.org/groups/virt/virtio-win/virtio-win.repo   -O /etc/yum.repos.d/virtio-win.repo
yum install virtio-win
yum --enablerepo=virtio-win-latest upgrade virtio-win


## BUGS
win2016 bsod install workaround

https://gist.github.com/jorritfolmer/d01194a00f440ad257bd56d51baddc2d

Extraneous messages:
https://patchwork.kernel.org/patch/10048427/
Add supress_ignore_msrs_prints as well

## References:
KVM Install
https://www.linuxtechi.com/install-kvm-hypervisor-on-centos-7-and-rhel-7/
Cloning
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/cloning-a-vm
Nested Virt
https://www.linuxtechi.com/enable-nested-virtualization-kvm-centos-7-rhel-7/
Windows
https://medium.com/@piecritic/how-i-learned-to-stop-crying-and-install-windows-server-on-kvm-9e56fe1a8740
Adding VirtIO to a existing Image
https://easyengine.io/tutorials/kvm/enable-virtio-existing-vms/



# openshift-windows
Windows Nodes in OpenShift

This current is tested on Vmware, with two machines, one running OpenShift 3.10 on RHEL 7.5.
A full openshift subscription is required.

The Windows Node is Windows Server Core 1803.
The Windows node requires it to be enabled for Ansible.
bin/winansible.ps1 set's up the windows node for ansible.

## Repos for Openshift Windows:

https://github.com/openshift/openshift-windows

## How to Use:

### Requirements:

1. Linux node with host name set, and static ip, and a proper search domain
2. Windows node with a hostname set, and dhcp that returns same ip all the time, matching hostname.
3. The windows node must have the correct host name, make sure you rename it.

### Overview:

1. Install two nodes, one with RHEL 7.5 and one with Windows 1803.
2. Setup DNS for both nodes, and search domain so the hosts can be found by both there short name, and there fully qualified name.
3. Make sure the windows node can use DHCP to find its IP address.
4. Make sure the Mac address is unique for the windows node in the first 5 bytes.
5. Login to root, and install git
6. git clone repo
7. cd repo (Either hybrid or opepnshift-windows)
8. Run allinone.sh

Important Note: The Windows Node must run on a physical box, or a environment that supports nested virt, with passthru configured on the VM. 

./allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password

### Examples:

Linux Host Name - node01 or openshift or linuxnode
Windows Host Name: winnode01 or windows 
Internal Domain: ncc9.com
Openshift Public URL: openshift.ncc9.com
App Public URL: example: app.openshift.ncc9.com
Username:  example: openshift
Password:  SuperSecret


9. cd ..
10. Run ansible-playbook ovn-presetup.yml
11. Run ansible-playbook ovn-postsetup.yml
12. Prepare Windows Machine
    A. RDP To windows console (Or use vmware console)
    B. From Command Prompt: (To Enable Ansible)
         i. type: powershell 
        ii. type: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        iii. Invoke-WebRequest -Uri https://raw.githubusercontent.com/openshift/hybrid/master/bin/winansible.ps1 -OutFile "winansible.ps1" -UseDefaultCredentials
        iv. .\winansible.ps1
        v.   Rename-Computer -NewName "winnode01" -Restart -Force
        vi.  Disconnect from windows.
13. copy the group_vars/windows.example to group_vars/windows
14. Add a user name and password to group_vars/windows
15. ansible-playbook windows.yml

## Known Issues:

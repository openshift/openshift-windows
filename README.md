# openshift-windows
Windows Nodes in OpenShift

This current is tested on Vmware, with two machines, one running OpenShift 3.11 on RHEL 7.5.
A full openshift subscription is required.

The Windows Node is Windows Server Core 2019/Windows Datacenter Edition 2019.
The Windows node requires it to be enabled for Ansible.
bin/winansible.ps1 set's up the windows node for ansible.

How to Use:

## Repos for Openshift Windows:

Supported

http:/github.com/openshift/openshift-windows

Upstream:

http://github.com/glennswest/openshift-windows

Requirements:
1. Linux node with host name set, and static ip, and a proper search domain
2. Windows node with a hostname set, and dhcp that returns same ip all the time, matching hostname. (Windows 2019 Datacenter Edition)
3. The windows node must have the correct host name, make sure you rename it.

Overview:
1. Install two nodes, one with RHEL 7.5 and one with Windows 1803.
2. Setup DNS for both nodes, and search domain so the hosts can be found by both there short name, and there fully qualified name.
3. Make sure the windows node can use DHCP to find its IP address.
4. Make sure the Mac address is unique for the windows node in the first 5 bytes.
5. Login to root, and install git
6. git clone repo
7. cd repo (Either hybrid or opepnshift-windows)
8. Run allinone.sh

Important Note: The Windows Node must run on a physical box, or a environment that supports nested virt, with passthru configured on the VM. 

./allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password rhnusername rhnpassword

Arguments Examples:

Linux Host Name - node01 or openshift or linuxnode
Windows Host Name: winnode01 or windows 
Internal Domain: ncc9.com 
Openshift Public URL: openshift.ncc9.com 
App Public URL: example: app.openshift.ncc9.com
Username:  example: openshift 
Password:  SuperSecret 
rhnusername: A Red Hat Network Username - For OpenShift and RHEL Subscription 
rhnpassword: A Red Hat Network Password 


9. cd .. 
10. Prepare Windows Machine 
    A. RDP To windows console (Or use vmware console) 
    B. From Command Prompt: (To Enable Ansible) be sure to specify the version of OpenShift to be installed. The command below assumes 3.11 specify a different version if required
         i. type: powershell  
        ii. type: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
        iii. Invoke-WebRequest -Uri https://raw.githubusercontent.com/openshift/openshift-windows/master/3.11/bin/winansible.ps1 -OutFile "winansible.ps1" -UseDefaultCredentials 
        iv. .\winansible.ps1 
        v.   Rename-Computer -NewName "winnode01" -Restart -Force 
        vi.  Disconnect from windows. 
11. copy the group_vars/windows.example to group_vars/windows 
12. Add a user name and password to group_vars/windows 
13. ansible-playbook windows.yml 

## Azure
openshift-windows 3.11 now supports Microsoft Azure Cloud. A full ARM template is now included, and has been shown to work. 

## Known Issues/ Changes:
1.Azure testing is current in process. Azure will require a further update to fucntion.  
2. The 3.11 branch requires 2 additional arguments, rhnusername and rhnpassword 
3. Nested Virt is no longer required 

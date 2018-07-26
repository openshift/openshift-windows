# OpenShift and Windows

## TODO on this README
* Change links to OCP 3.10 when it's out
* Remove need to switch branches when 3.10 goes out
* Remove static hostnames referenced everywhere
* Ensure allinone.sh command is correct

## Tested Configurations

This has been tested on the following platforms:
* Vmware
* RHV
* KVM

The following versions of softare were tested:
* OpenShift 3.10
* RHEL 7.5
* Windows Server Core 1709
* Windows Kubelet 1.10.5
* Ansible 2.4.6

The following node count was tested:
* One OpenShift Master node
* One Microsoft Windows node

The following repo is used here:

* https://github.com/openshift/openshift-windows

## Requirements

We have attempted to automate many of the tasks required to implement this integration. However, there are some steps and requirements that must be fulfilled manually. These are listed below.

* OpenShift subscription
* One node provisioned with RHEL 7.5
* One node provisioned with Windows Server Core 1709
* Linux node with host name set, and static ip, and a proper search domain
* Windows node should be configured to use DHCP, which provides a static IP and hostname
* Make sure the Mac address is unique for the windows node in the first 5 bytes.
* The RHEL 7.5 system must be subscribed to the proper repositories, as listed in the [OpenShift Documentation](https://access.redhat.com/documentation/en-us/openshift_container_platform/3.9/html/installation_and_configuration/installing-a-cluster#host-registration).
* The RHEL 7.5 system must have a valid SSH key, as listed in the [OpenShift Documentation](https://access.redhat.com/documentation/en-us/openshift_container_platform/3.9/html/installation_and_configuration/installing-a-cluster#ensuring-host-access)
* You must have full DNS resolution for both nodes. You can refere to the [OpenShift Documentation](https://access.redhat.com/documentation/en-us/openshift_container_platform/3.9/html/installation_and_configuration/installing-a-cluster#envirornment-requirements). In addition, you *must* ensure that your short, local hostname and public hostname match.
* Your hostname must not exceed 32 characters


## Installation Instructions 

### Pre-Requisites

Log into the RHEL 7.5 host, update and reboot

```
yum -y update; reboot
```

Confirm DNS is working properly

```
# nslookup <hostname>
# nslookup <fqdn>
```

### Install OpenShift

We will first acquire the scripts to automate simple Linux/Windows clusters.  Then we will install OpenShift via the allinone.sh script.

```
# cd ~; mkdir ovn; cd ovn
# yum -y install git ansible bash-completion
# git clone https://github.com/openshift/openshift-windows.git
# git checkout origin/3.10
# cd openshift-windows
# standalone/3.10/allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password
```

Example list of arguments for the `allinone.sh` script
* Linux Host Name - node01 or openshift or linuxnode
* Windows Host Name: winnode01 or windows 
* Internal Domain: ncc9.com
* Openshift Public URL: openshift.ncc9.com
* App Public URL: example: app.openshift.ncc9.com
* Username:  example: openshift
* Password:  SuperSecret




### Install the OVN Network

We need to give OpenShift an overlay network. Windows Containers will not work with OVS.  OpenShift is moving to OVN in the first quarter of next year. Install the OVN network binaries and software.

```
# ansible-playbook ovn_presetup.yml
```

Tell OpenShift to use the OVN network.

```
# ansible-playbook ovn_postsetup.yml
```

### Prepare the Windows Node

TBD

## Legacy Steps that need to be cleaned up once it's all figured out.

9. cd ..
10. Run ansible-playbook ovn-presetup.yml
11. Run ansible-playbook ovn-postsetup.yml
12. Prepare Windows Machine
    A. RDP To windows console (Or use vmware console)
    B. From Command Prompt: (To Enable Ansible)
         i. type: powershell 
        ii. type: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        iii. Invoke-WebRequest -Uri https://raw.githubusercontent.com/glennswest/hybrid/master/bin/winansible.ps1 -OutFile "winansible.ps1" -UseDefaultCredentials
        iv. .\winansible.ps1
        v.   Rename-Computer -NewName "winnode01" -Restart -Force
        vi.  Disconnect from windows.
13. copy the group_vars/windows.example to group_vars/windows
14. Add a user name and password to group_vars/windows
15. ansible-playbook windows.yml

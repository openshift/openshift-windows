choco install wget -y
wget.exe https://cloudbase.it/downloads/openvswitch-hyperv-2.7.0-certified.msi -O openvswitch.msi
msiexec /i openvswitch.msi ADDLOCAL="OpenvSwitchCLI,OpenvSwitchDriver,OVNHost" /qn
NetSh Advfirewall set allprofiles state off
setx PATH "C:\Program Files\Cloudbase Solutions\Open vSwitch\bin;$env:path" -m
Start-Service ovs-vswitchd

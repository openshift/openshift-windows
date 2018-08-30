$a = Test-Path "C:\k\network_setup.lock"
IF ($a -eq "True") {Write-Host "Network Already Installed";exit}
Write-Host "Installing Network"
date > c:\k\network_setup.lock
$ErrorActionPreference = "SilentlyContinue"

# The name is saved in the docker setup
$roughname = Get-Content "C:\k\interface.txt" | Out-String
$INTERFACE_ALIAS= $roughname -replace "`n|`r",""
echo $INTERFACE_ALIAS

Stop-Service ovs-vswitchd -force; Get-VMSwitch -SwitchType External | Disable-VMSwitchExtension "Cloudbase Open vSwitch Extension"
Get-VMSwitch -SwitchType External | Set-VMSwitch -AllowManagementOS $false
# Ignore the error from the first command
Get-VMSwitch -SwitchType External | Set-VMSwitch -AllowManagementOS $false
ovs-vsctl --no-wait --may-exist add-br br-ex
ovs-vsctl --no-wait add-port br-ex "$INTERFACE_ALIAS"
Get-VMSwitch -SwitchType External | Enable-VMSwitchExtension "Cloudbase Open vSwitch Extension"; sleep 2; Restart-Service ovs-vswitchd
# Clone the MAC Address of $INTERFACE_ALIAS on br-ex
$MAC_ADDRESS=$(Get-NetAdapter "$INTERFACE_ALIAS").MacAddress
$FAKE_MAC_ADDRESS=$MAC_ADDRESS.Substring(0,15)+"99"
Set-NetAdapter -Name "$INTERFACE_ALIAS" -MacAddress $FAKE_MAC_ADDRESS -Confirm:$false
Set-NetAdapter -Name br-ex -MacAddress $MAC_ADDRESS -Confirm:$false
# br-ex will get all the interface details from the DHCP server now
Enable-NetAdapter br-ex
# First time may not work
Set-NetAdapter -Name br-ex -MacAddress $MAC_ADDRESS -Confirm:$false
# Make sure arp etc is update to date
ping 8.8.8.8
Write-Host "SDN Network is setup"

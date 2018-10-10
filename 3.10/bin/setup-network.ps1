$a = Test-Path "C:\k\network_setup.lock"
IF ($a -eq "True") {Write-Host "Network Already Installed";exit}
Write-Host "Installing Network"
date > c:\k\network_setup.lock
$ErrorActionPreference = "SilentlyContinue"

# The name is saved in the docker setup
$roughname = Get-Content "C:\k\interface.txt" | Out-String
$INTERFACE_ALIAS= $roughname -replace "`n|`r",""
echo $INTERFACE_ALIAS

Import-Module "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\HostNetworkingService\HostNetworkingService.psm1"
Import-Module "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\OVS\OVS.psm1"
Import-Module "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\HNSHelper\HNSHelper.psm1"

# # There should be only one transparent network
$HNS_NW = Get-HNSNetwork | where {$_.type -eq "transparent"}
$HNS_ID = $HNS_NW.Id
Disable-OVSOnHNSNetwork $HNS_ID
ovs-vsctl --if-exists --no-wait del-br br-ex
ovs-vsctl --no-wait --may-exist add-br br-ex
ovs-vsctl --no-wait add-port br-ex "vEthernet (${INTERFACE_ALIAS})" -- set interface  "vEthernet (${INTERFACE_ALIAS})" type=internal
ovs-vsctl --no-wait add-port br-ex "${INTERFACE_ALIAS}"
Stop-Service ovs-vswitchd
Enable-OVSOnHNSNetwork $HNS_ID

Start-Service ovs-vswitchd
sleep 2
Restart-Service ovs-vswitchd

# Make sure arp etc is update to date
ping 8.8.8.8
Write-Host "SDN Network is setup"

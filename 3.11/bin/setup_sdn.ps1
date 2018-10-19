Param(
    [Parameter(Mandatory=$true)]
    [string]$OVSSubnet,
    [Parameter(Mandatory=$true)]
    [string]$OVSGateway,
    [Parameter(Mandatory=$false)]
    [string]$OVSNetworkName="external",
    [Parameter(Mandatory=$false)]
    [int]$OVSCmdTimeout=30
)

$ErrorActionPreference = "Stop"


function New-OVSNetwork {
    $primaryIfIndex = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").ifIndex
    $mainInterface = Get-NetAdapter -InterfaceIndex $primaryIfIndex
    [array]$networks = Get-HnsNetwork | Where-Object {
        ($_.Name -eq $OVSNetworkName) -and ($_.Type -eq "Transparent")
    }
    if($networks) {
        if($networks.Count -gt 1) {
            # If we reach this, something weird happened
            Throw "More than one OVS network was found"
        }
        $adapterName = $networks[0].NetworkAdapterName
        # Clean up existing network to refresh its subnet and gateway values
        $networks | Remove-HnsNetwork
    } else {
        $adapterName = $mainInterface.InterfaceAlias
    }
    $net = New-HnsNetwork -Name $OVSNetworkName -Type "Transparent" -AdapterName $adapterName `
                          -AddressPrefix $OVSSubnet -Gateway $OVSGateway
    # Check if the virtual adapter is present post HNS network creation
    $virtualAdapterName = "vEthernet ($($net.NetworkAdapterName))"
    $adapter = Get-NetAdapter -Name $virtualAdapterName -ErrorAction SilentlyContinue
    if(!$adapter) {
        Throw "The virtual adapter $virtualAdapterName doesn't exist post HNS network creation"
    }
    return $net
}


try {
    Import-Module HostNetworkingService
    Import-Module HNSHelper -DisableNameChecking
    Import-Module OVS -DisableNameChecking

    $net = New-OVSNetwork
    Set-Service "ovs-vswitchd" -StartupType Disabled
    Stop-Service "ovs-vswitchd" -Force -ErrorAction SilentlyContinue
    Disable-OVSOnHNSNetwork $net.ID
    $bridgeName = "vEthernet ($($net.NetworkAdapterName))"
    ovs-vsctl.exe --timeout $OVSCmdTimeout --if-exists --no-wait del-br "$bridgeName"
    if($LASTEXITCODE) {
        Throw "Failed to cleanup existing OVS bridge"
    }
    ovs-vsctl.exe --timeout $OVSCmdTimeout --no-wait --may-exist add-br "$bridgeName"
    if($LASTEXITCODE) {
        Throw "Failed to add the OVS bridge"
    }
    ovs-vsctl.exe --timeout $OVSCmdTimeout --no-wait --may-exist add-port "$bridgeName" "$($net.NetworkAdapterName)"
    if($LASTEXITCODE) {
        Throw "Failed to add the HNS interface to OVS bridge"
    }
    Enable-OVSOnHNSNetwork $net.ID
    Set-Service "ovs-vswitchd" -StartupType Automatic
    Start-Service "ovs-vswitchd"
    Write-Output "The SDN network setup is ready"
} catch {
    Write-Output $_.ScriptStackTrace
    exit 1
}
exit 0

$a = Test-Path "C:\k\docker_create.lock"
IF ($a -eq "True") {Write-Host "Docker Network Already Created";exit}
Write-Host "Creating Docker Network"
date > c:\k\docker_create.lock
$roughname = Get-NetRoute | Where-Object -FilterScript {$_.NextHop -Ne "::"} | Where-Object -FilterScript { $_.NextHop -Ne "0.0.0.0" } | Where-Object -FilterScript { ($_.NextHop.SubString(0,6) -Ne "fe80::") } | Get-NetAdapter | Format-List -Property "Name"  | Out-String
$roughname = $roughname -creplace '(?m)^\s*\r?\n',''
$roughname = ($roughname -split '\n')[0]
echo $roughname
$INTERFACE_ALIAS= $roughname.Substring(7) -replace "`n|`r",""
echo $INTERFACE_ALIAS
echo $INTERFACE_ALIAS > C:\k\interface.txt
# multinode
$roughnet = Get-Content "C:\k\host.subnet" | Out-String
$subnetq= $roughnet -replace "`n|`r",""
$subnet = $subnetq.Trim('"')
echo $subnet
$netparts=$subnet.split('/');
echo $netparts[0]
$dotparts=$netparts[0].split('.');
$gateway = $dotparts[0] + "." + $dotparts[1] + "." + $dotparts[2] + "." + "1"
echo $gateway

# Single node
docker network create -d transparent --gateway $gateway --subnet $subnet -o com.docker.network.windowsshim.interface="${INTERFACE_ALIAS}"  external

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
#docker network create -d transparent --gateway 10.128.2.1 --subnet 10.128.2.0/24 -o com.docker.network.windowsshim.interface="Ethernet0" external
# Single node
docker network create -d transparent --gateway 10.128.1.1 --subnet 10.128.1.0/24 -o com.docker.network.windowsshim.interface=$INTERFACE_ALIAS  external


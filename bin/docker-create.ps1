 = Test-Path "C:\k\docker_create.lock"
IF ($a -eq "True") {Write-Host "Docker Network Already Created";exit}
Write-Host "Creating Docker Network"
date > c:\k\docker_create.lock
$roughname = Get-NetAdapter | where adminstatus -eq "up" | Format-List -Property "Name" | Out-String
$NetAdapterName = $roughname.Substring(11)
# multinode
#docker network create -d transparent --gateway 10.128.2.1 --subnet 10.128.2.0/24 -o com.docker.network.windowsshim.interface="Ethernet0" external
# Single node
docker network create -d transparent --gateway 10.128.1.1 --subnet 10.128.1.0/24 -o com.docker.network.windowsshim.interface=$NetAdapterName external

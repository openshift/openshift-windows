$a = Test-Path "C:\k\docker_create.lock"
IF ($a -eq "True") {Write-Host "Docker Network Already Created";exit}
Write-Host "Creating Docker Network"
date > c:\k\docker_create.lock
docker network create -d transparent --gateway 10.128.7.1 --subnet 10.128.7.0/24 -o com.docker.network.windowsshim.interface="Ethernet 3" external

mkdir \k
Install-WindowsFeature -Name Hyper-V, RSAT-Hyper-V-Tools
Find-PackageProvider -Name "Nuget" | Install-PackageProvider -Verbose -Force
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Confirm
Install-Package Docker -ProviderName DockerMsftProvider -Force
Install-Package PSWindowsUpdate -Force
Get-WUInstall -AcceptAll

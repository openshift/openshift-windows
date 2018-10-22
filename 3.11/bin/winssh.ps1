Add-WindowsCapability -Online -Name OpenSSH.Server
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd


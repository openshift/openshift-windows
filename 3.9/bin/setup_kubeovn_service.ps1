$powershell = (Get-Command powershell).Source
$scriptPath = 'C:\k\hybrid\3.9\bin\start_kubeovn.ps1'
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
$serviceName = "kubeovn"
nssm install $serviceName $powershell $arguments
nssm set kubeovn DisplayName Kubeovn
nssm set kubeovn Description OVN For OpenShift
nssm set kubeovn Start SERVICE_AUTO_START
nssm set kubeovn AppStdout C:\k\hybrid\logs\kubeovn.log
nssm set kubeovn AppStderr C:\k\hybrid\logs\kubeovn.log
nssm set kubeovn AppRotateFiles 1
nssm set kubeovn AppRotateOnline 1
nssm set kubeovn AppRotateSeconds 86400
nssm set kubeovn AppRotateBytes 1048576

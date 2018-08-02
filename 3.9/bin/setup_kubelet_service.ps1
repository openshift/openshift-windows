$powershell = (Get-Command powershell).Source
$scriptPath = "C:\k\hybrid\3.9\bin\start_kubelet.ps1"
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
$serviceName = "kubelet"
nssm install $serviceName $powershell $arguments
nssm set kubelet DisplayName Kubelet
nssm set kubelet Description Kubelet OVN For OpenShift
nssm set kubelet Start SERVICE_AUTO_START
nssm set kubelet AppStdout C:\k\hybrid\logs\kubelet.log
nssm set kubelet AppStderr C:\k\hybrid\logs\kubelet.log
nssm set kubelet AppRotateFiles 1
nssm set kubelet AppRotateOnline 1
nssm set kubelet AppRotateSeconds 86400
nssm set kubelet AppRotateBytes 1048576

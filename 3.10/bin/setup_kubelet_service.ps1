$powershell = (Get-Command powershell).Source
$scriptPath = "C:\k\hybrid\3.10\bin\start_kubelet.ps1"
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
$serviceName = "ocpkubelet"
nssm install $serviceName $powershell $arguments
nssm set ocpkubelet DisplayName ocpkubelet
nssm set ocpkubelet Description Kubelet For OpenShift
nssm set ocpkubelet Start SERVICE_AUTO_START
nssm set ocpkubelet AppStdout C:\k\hybrid\logs\kubelet.log
nssm set ocpkubelet AppStderr C:\k\hybrid\logs\kubelet.log
nssm set ocpkubelet AppRotateFiles 1
nssm set ocpkubelet AppRotateOnline 1
nssm set ocpkubelet AppRotateSeconds 86400
nssm set ocpkubelet AppRotateBytes 1048576

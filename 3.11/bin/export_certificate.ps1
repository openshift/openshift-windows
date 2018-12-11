$cloudbaseCertID = "62912E07C6438E93A1AD1863637DD7484461B98A"
$cert = (Get-ChildItem -Path "Cert:\LocalMachine\TrustedPublisher\${cloudbaseCertID}")
Export-Certificate -Cert $cert -FilePath $PSScriptRoot\cloudbase.sst -Type SST

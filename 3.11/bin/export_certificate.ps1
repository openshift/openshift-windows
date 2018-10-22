$cert = (Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher\62912E07C6438E93A1AD1863637DD7484461B98A)
Export-Certificate -Cert $cert -FilePath .\cloudbase.sst -Type SST




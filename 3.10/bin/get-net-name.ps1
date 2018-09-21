$roughname = Get-NetRoute | Where-Object -FilterScript {$_.NextHop -Ne "::"} | Where-Object -FilterScript { $_.NextHop -Ne "0.0.0.0" } | Where-Object -FilterScript { ($_.NextHop.SubString(0,6) -Ne "fe80::") } | Get-NetAdapter | Format-List -Property "Name"  | Out-String
$roughname = $roughname -creplace '(?m)^\s*\r?\n',''
$roughname = ($roughname -split '\n')[0]
$INTERFACE_ALIAS= $roughname.Substring(7) -replace "`n|`r",""
echo $INTERFACE_ALIAS

New-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\' `
     -Name  'DisabledComponents' -Value '0xffffffff' -PropertyType 'DWord'


<#PSScriptInfo 
.VERSION 1.0.0 
.GUID e009159d-97e2-492a-a289-42426518dd41 
.AUTHOR Arjun Bahree 
.COMPANYNAME 
.COPYRIGHT 
.TAGS Windows PowerShell DiskPartition OSDisk 
.LICENSEURI https://github.com/bahreex/Bahree-PowerShell-Library/blob/master/LICENSE 
.PROJECTURI https://github.com/bahreex/Bahree-PowerShell-Library/tree/master/General 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES 
#>

<# 
.DESCRIPTION 
 Lets you extend/Increase the OS Drive Partition Size for any Windows based Machine. 
#> 

<# 
.SYNOPSIS 
    Lets you extend/Increase the OS Drive Partition Size for any Windows based Machine. 
 
.DESCRIPTION 
    This script lets you extend/Increase the OS Drive Partition size for any Windows based Machine by adding the entire 
    unallocated space available on the OS Disk, if any. This script is particularly useful for extending the OS Drive 
    partition for Windows based Azure VM's, after the VM OS Disk size has been Increased from outside the VM using 
    PowerShell or Azure Portal. This is so because the Increase in size done for the VM OS Disk from outside does not 
    automatically get added to the OS Drive partition, and shows as unallocated space on the OS Disk of the VM. You will 
    have to manually extend the OS Drive partition from within the VM OS to add the unallocated space to the OS 
    partition. This script helps to automate the same process end-to-end. You need to be already logged into your Azure 
    account through PowerShell before calling this script. 
 
.EXAMPLE 
    .\Extend-WinOSDiskSize.ps1 
     
.Notes 
    Author: Arjun Bahree 
    E-mail: arjun.bahree@gmail.com 
    Creation Date: 28/Dec/2017 
    Last Revision Date: 28/Dec/2017 
    Development Environment: VS Code IDE 
    PS Version: 5.1 
    Platform: Windows 
#>

[CmdletBinding()]
param ()    

# Iterate through all the disks on the Windows machine
foreach($disk in Get-Disk)
{
    # Check if the disk in context is a Boot and System disk
    if((Get-Disk -Number $disk.number).IsBoot -And (Get-Disk -Number $disk.number).IsSystem)
    {
        # Get the drive letter assigned to the disk partition where OS is installed
        $driveLetter = (Get-Partition -DiskNumber $disk.Number | where {$_.DriveLetter}).DriveLetter
        Write-verbose "Current OS Drive: $driveLetter :\"

        # Get current size of the OS parition on the Disk
        $currentOSDiskSize = (Get-Partition -DriveLetter $driveLetter).Size        
        Write-verbose "Current OS Partition Size: $currentOSDiskSize"

        # Get Partition Number of the OS partition on the Disk
        $partitionNum = (Get-Partition -DriveLetter $driveLetter).PartitionNumber
        Write-verbose "Current OS Partition Number: $partitionNum"

        # Get the available unallocated disk space size
        $unallocatedDiskSize = (Get-Disk -Number $disk.number).LargestFreeExtent
        Write-verbose "Total Unallocated Space Available: $unallocatedDiskSize"

        # Get the max allowed size for the OS Partition on the disk
        $allowedSize = (Get-PartitionSupportedSize -DiskNumber $disk.Number -PartitionNumber $partitionNum).SizeMax
        Write-verbose "Total Partition Size allowed: $allowedSize"

        if ($unallocatedDiskSize -gt 0 -And $unallocatedDiskSize -le $allowedSize)
        {
            $totalDiskSize = $allowedSize
            
            # Resize the OS Partition to Include the entire Unallocated disk space
            $resizeOp = Resize-Partition -DriveLetter C -Size $totalDiskSize
            Write-verbose "OS Drive Resize Completed $resizeOp"
        }
        else {
            Write-Verbose "There is no Unallocated space to extend OS Drive Partition size"
        }
    }   
}


function New-DiskPartFat32Partition {
<#
    .SYNOPSIS
        Uses DISKPART.EXE to create a new FAT32 system partition. This permits mocking of DISKPART calls.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Int32] $DiskNumber,

        [Parameter(Mandatory)]
        [System.Int32] $PartitionNumber
    )
    process {

        @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=fat32 label="System"
"@ | & "$env:SystemRoot\System32\DiskPart.exe" | Out-Null;

    } #end process
} #end function

function Get-DiskImageDriveLetter {
<#
    .SYNOPSIS
        Return a disk image's associated/mounted drive letter.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $DiskImage,

        [Parameter(Mandatory)]
        [ValidateSet('Basic','System','IFS')]
        [System.String] $PartitionType
    )
    process {

        # Microsoft.Vhd.PowerShell.VirtualHardDisk
        $driveLetter = Storage\Get-Partition -DiskNumber $DiskImage.DiskNumber |
            Where-Object Type -eq $PartitionType |
                Where-Object DriveLetter |
                    Select-Object -Last 1 -ExpandProperty DriveLetter;

        if (-not $driveLetter) {

            throw ($localized.CannotLocateDiskImageLetter -f $DiskImage.Path);
        }
        return $driveLetter;
    }
} #end function

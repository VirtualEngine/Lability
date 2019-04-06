function Set-DiskImageBootVolume {
<#
    .SYNOPSIS
        Sets the boot volume of a mounted disk image.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle
    )
    process {

        switch ($PartitionStyle) {

            'MBR' {

                Set-DiskImageBootVolumeMbr -Vhd $Vhd;
                break;
            }
            'GPT' {

                Set-DiskImageBootVolumeGpt -Vhd $Vhd;
                break;
            }
        } #end switch

    } #end process
} #end function

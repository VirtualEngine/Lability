function SetDiskImageBootVolume {

<#
    .SYNOPSIS
        Sets the boot volume of a mounted disk image.
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle
    )
    process {

        switch ($PartitionStyle) {

            'MBR' {

                SetDiskImageBootVolumeMbr -Vhd $Vhd;
                break;
            }
            'GPT' {

                SetDiskImageBootVolumeGpt -Vhd $Vhd;
                break;
            }
        } #end switch

    } #end process

}


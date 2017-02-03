function Resolve-LabVMImage {
<#
    .SYNOPSIS
        Resolves a virtual machine's Lability image.
#>
    param (
        ## VM name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name
    )
    process {

        Get-VM -Name $Name |
            Get-VMHardDiskDrive |
                Select-Object -First 1 -ExpandProperty $Path |
                    Resolve-LabImage;

    } #'end process
} #end function Resolve-LabVMImage

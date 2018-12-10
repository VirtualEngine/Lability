function Resolve-LabVMImage {
<#
    .SYNOPSIS
        Resolves a virtual machine's Lability image.
#>
    [CmdletBinding()]
    param (
        ## VM name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name
    )
    process {

        Hyper-V\Get-VM -Name $Name |
            Hyper-V\Get-VMHardDiskDrive |
                Select-Object -First 1 -ExpandProperty $Path |
                    Resolve-LabImage;

    } #'end process
} #end function Resolve-LabVMImage

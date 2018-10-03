function Resolve-LabImage {
<#
    .SYNOPSIS
        Resolves a Lability image by its path.
    .DESCRIPTION
        When running Remove-LabVM there is not always a configuration document supplied. This
        causes issues removing a VMs VHD/X file. The ResolveLabImage function locates the image
        by its physical path.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Path
    )
    process {

        $vhdParentPaths = Resolve-VhdHierarchy -VhdPath $Path;
        Write-Output (Get-LabImage | Where-Object ImagePath -in $vhdParentPaths);

    } #end process
} #end function Resolve-LabImage

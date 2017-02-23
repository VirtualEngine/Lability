function Get-WindowsImageByName {
<#
    .SYNOPSIS
        Locates the specified WIM image name by its index.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # WIM image path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ImagePath,

        # Windows image index
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Int32] $ImageIndex
    )
    process {

        WriteVerbose ($localized.LocatingWimImageName -f $ImageIndex);
        Get-WindowsImage -ImagePath $ImagePath -Verbose:$false |
            Where-Object ImageIndex -eq $ImageIndex |
                Select-Object -ExpandProperty ImageName;

    } #end process
} #end function Get-WindowsImageByName

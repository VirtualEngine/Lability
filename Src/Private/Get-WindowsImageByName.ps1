function Get-WindowsImageByName {
<#
    .SYNOPSIS
        Locates the specified WIM image index by its name, i.e. SERVERSTANDARD or SERVERDATACENTERSTANDARD.
    .OUTPUTS
        The WIM image index.
#>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        # WIM image path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ImagePath,

        # Windows image name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ImageName
    )
    process {

        Write-Verbose -Message ($localized.LocatingWimImageIndex -f $ImageName);
        Get-WindowsImage -ImagePath $ImagePath -Verbose:$false |
            Where-Object ImageName -eq $ImageName |
                Select-Object -ExpandProperty ImageIndex;

    } #end process
} #end function Get-WindowsImageByName

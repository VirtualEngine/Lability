function Get-LabHostDefault {
<#
    .SYNOPSIS
        Gets the lab host's default settings.
    .DESCRIPTION
        The Get-LabHostDefault cmdlet returns the lab host's current settings.
    .LINK
        Set-LabHostDefault
        Reset-LabHostDefault
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ( )
    process {

        Get-ConfigurationData -Configuration Host;

    } #end process
} #end function Get-LabHostDefault


function Get-LabHostDefaults {
<#
    .SYNOPSIS
        Gets the lab host's default settings.
    .DESCRIPTION
        The Get-LabHostDefault cmdlet returns the lab host's current settings.
    .NOTES
        Proxy function replacing alias to enable warning output.
    .LINK
        Set-LabHostDefault
        Reset-LabHostDefault
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param ( )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Get-LabHostDefaults','Get-LabHostDefault');
        Get-LabHostDefault @PSBoundParameters;


    } #end process
} #end function Get-LabHostDefaults

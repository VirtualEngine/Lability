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

        GetConfigurationData -Configuration Host;

    } #end process

}


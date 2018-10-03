function Reset-LabHostDefault {
<#
    .SYNOPSIS
        Resets lab host default settings to default.
    .DESCRIPTION
        The Reset-LabHostDefault cmdlet resets the lab host's settings to default values.
    .LINK
        Get-LabHostDefault
        Set-LabHostDefault
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param ( )
    process {

        Remove-ConfigurationData -Configuration Host;
        Get-LabHostDefault;

    } #end process
} #end function Reset-LabHostDefault

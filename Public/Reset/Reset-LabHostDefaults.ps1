function Reset-LabHostDefaults {

<#
    .SYNOPSIS
        Resets lab host default settings to default.
    .DESCRIPTION
        The Reset-LabHostDefault cmdlet resets the lab host's settings to default values.
    .NOTES
        Proxy function replacing alias to enable warning output.
    .LINK
        Get-LabHostDefault
        Set-LabHostDefault
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param ( )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Reset-LabHostDefaults','Reset-LabHostDefault');
        Reset-LabHostDefault @PSBoundParameters;

    } #end process

}


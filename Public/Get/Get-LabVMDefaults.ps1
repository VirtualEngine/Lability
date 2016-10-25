function Get-LabVMDefaults {

<#
    .SYNOPSIS
        Gets the current lab virtual machine default settings.
    .NOTES
        Proxy function replacing alias to enable warning output.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param ( )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Get-LabVMDefaults','Get-LabVMDefault');
        Get-LabVMDefault @PSBoundParameters;

    }

}


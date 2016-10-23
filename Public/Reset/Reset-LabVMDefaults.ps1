function Reset-LabVMDefaults {

<#
    .SYNOPSIS
        Reset the current lab virtual machine default settings back to defaults.
    .NOTES
        Proxy function replacing alias to enable warning output.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param ( )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Reset-LabVMDefaults','Reset-LabVMDefault');
        Reset-LabVMDefault @PSBoundParameters;

    }

}


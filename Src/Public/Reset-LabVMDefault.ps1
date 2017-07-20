function Reset-LabVMDefault {
<#
    .SYNOPSIS
        Reset the current lab virtual machine default settings back to defaults.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param ( )
    process {

        Remove-ConfigurationData -Configuration VM;
        Get-LabVMDefault;

    }
} #end function

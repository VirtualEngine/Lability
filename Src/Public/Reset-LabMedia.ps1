function Reset-LabMedia {
<#
    .SYNOPSIS
        Reset the lab media entries to default settings.
    .DESCRIPTION
        The Reset-LabMedia removes all custom media entries, reverting them to default values.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param ( )
    process {

        Remove-ConfigurationData -Configuration CustomMedia;
        Get-Labmedia;

    }
} #end function Reset-LabMedia

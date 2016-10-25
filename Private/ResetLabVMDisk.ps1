function ResetLabVMDisk {

<#
    .SYNOPSIS
        Removes and resets lab VM disk file (VHDX) configuration.
#>
    [CmdletBinding()]
    param (
        ## VM/node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        RemoveLabVMSnapshot -Name $Name;
        RemoveLabVMDisk @PSBoundParameters;
        SetLabVMDisk @PSBoundParameters;
    } #end process

}


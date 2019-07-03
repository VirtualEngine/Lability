function Resolve-LabVMGenerationDiskPath {
<#
    .SYNOPSIS
        Resolves the specified VM name's target VHD/X path.
#>
    [CmdletBinding()]
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media,

        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;

        $resolveLabVMDiskPathParams = @{
            Name            = $Name;
            Generation      = $image.Generation;
            EnvironmentName = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).EnvironmentName;
        }
        $vhdPath = Resolve-LabVMDiskPath @resolveLabVMDiskPathParams

        return $vhdPath;

    } #end process
} #end function

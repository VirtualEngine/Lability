function Resolve-LabVMGenerationDiskPath {
<#
    .SYNOPSIS
        Resolves the specified VM name's target VHD/X path.
#>
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
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

        $hostDefaults = Get-ConfigurationData -Configuration Host;
        $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;
        $vhdName = '{0}.{1}' -f $Name, $image.Generation.ToLower();
        $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath $vhdName;
        return $vhdPath;

    } #end process
} #end function Resolve-LabVMGenerationDiskPath

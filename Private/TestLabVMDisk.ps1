function TestLabVMDisk {

<#
    .SYNOPSIS
        Checks whether the lab virtual machine disk (VHDX) is present.
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
        $hostDefaults = GetConfigurationData -Configuration Host;
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {
            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;
        }
        else {
            $image = Get-LabImage -Id $Media;
        }
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = $image.Generation;
        }
        if (-not $image) {
            ## This only occurs when a parent image is not available (#104).
            $vhd['MaximumSize'] = 136365211648; #127GB
            $vhd['Generation'] = 'VHDX';
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        TestDscResource -ResourceName VHD -Parameters $vhd;
    } #end process

}


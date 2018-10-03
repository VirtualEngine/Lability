function Test-LabVMDisk {
<#
    .SYNOPSIS
        Checks whether the lab virtual machine disk (VHDX) is present.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        $ConfigurationData,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {

        $hostDefaults = Get-ConfigurationData -Configuration Host;

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
            Type = 'Differencing';
        }

        if (-not $image) {

            ## This only occurs when a parent image is not available (#104).
            $vhd['MaximumSize'] = 136365211648; #127GB
            $vhd['Generation'] = 'VHDX';
        }

        Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        $testDscResourceResult = Test-LabDscResource -ResourceName VHD -Parameters $vhd;

        if ($Ensure -eq 'Absent') {

            return -not $testDscResourceResult;
        }
        else {

            return $testDscResourceResult;
        }

    } #end process
} #end function

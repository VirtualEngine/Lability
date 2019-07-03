function Set-LabVMDisk {
    <#
    .SYNOPSIS
        Sets a lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## VM/Node name
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

        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData -ErrorAction Stop;
        }
        else {

            $image = Get-LabImage -Id $Media -ErrorAction Stop;
        }

        $environmentName = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).EnvironmentName;
        $vhd = @{
            Name       = $Name;
            Path       = Resolve-LabVMDiskPath -Name $Name -EnvironmentName $environmentName -Parent;
            ParentPath = $image.ImagePath;
            Generation = $image.Generation;
            Type       = 'Differencing';
        }

        Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        [ref] $null = Invoke-LabDscResource -ResourceName VHD -Parameters $vhd;

    } #end process
} #end function

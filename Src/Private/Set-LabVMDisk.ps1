function Set-LabVMDisk {
<#
    .SYNOPSIS
        Sets a lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
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

        $hostDefaults = Get-ConfigurationData -Configuration Host;
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData -ErrorAction Stop;
        }
        else {

            $image = Get-LabImage -Id $Media -ErrorAction Stop;
        }

        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = $image.Generation;
        }

        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;

    } #end process
} #end function

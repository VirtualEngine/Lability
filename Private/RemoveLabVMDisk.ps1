function RemoveLabVMDisk {

<#
    .SYNOPSIS
        Removes lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding(SupportsShouldProcess)]
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
            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData -ErrorAction Stop;
        }
        else {
            $image = Get-LabImage -Id $Media -ErrorAction Stop;
        }
        if ($image) {
            ## If the parent image isn't there, the differencing VHD won't be either
            $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath "$Name.vhdx";
            if (Test-Path -Path $vhdPath) {
                ## Only attempt to remove the differencing disk if it's there (and xVHD will throw)
                if ($PSCmdlet.ShouldProcess($vhdPath)) {
                    $vhd = @{
                        Name = $Name;
                        Path = $hostDefaults.DifferencingVhdPath;
                        ParentPath = $image.ImagePath;
                        Generation = $image.Generation;
                        Ensure = 'Absent';
                    }
                    ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
                    [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;
                }
            }
        }
    } #end process

}


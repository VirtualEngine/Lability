function Remove-LabVMDisk {
<#
    .SYNOPSIS
        Removes lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        ## VM/node display name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media,

        ## VM/node name
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $NodeName = $Name,

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

        ## If the parent image isn't there, the differencing VHD won't be either!
        if ($image) {

            ## Ensure we look for the correct file extension (#182)
            $vhdFilename = '{0}.{1}' -f $Name, $image.Generation;
            $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath $vhdFilename;

            if (Test-Path -Path $vhdPath) {
                ## Only attempt to remove the differencing disk if it's there (and xVHD will throw)
                $vhd = @{
                    Name = $Name;
                    Path = $hostDefaults.DifferencingVhdPath;
                    ParentPath = $image.ImagePath;
                    Generation = $image.Generation;
                    Type = 'Differencing';
                    Ensure = 'Absent';
                }
                Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
                [ref] $null = Invoke-LabDscResource -ResourceName VHD -Parameters $vhd;
            }
        }

        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $resolveNodePropertyValueParams = @{
                NodeName = $NodeName;
                ConfigurationData = $ConfigurationData;
                NoEnumerateWildcardNode = $true;
                ErrorAction = 'Stop';
            }
            $node = Resolve-NodePropertyValue @resolveNodePropertyValueParams;
            if ($node.ContainsKey('HardDiskDrive')) {

                ## Remove additional HDDs
                $removeLabVirtualMachineHardDiskDriveParams = @{
                    NodeName = $node.NodeDisplayName;
                    HardDiskDrive = $node.HardDiskDrive;
                }
                $null = Remove-LabVirtualMachineHardDiskDrive @removeLabVirtualMachineHardDiskDriveParams;
            }
        }

    } #end process
} #end function

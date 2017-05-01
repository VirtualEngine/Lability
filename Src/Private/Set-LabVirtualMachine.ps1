function Set-LabVirtualMachine {
<#
    .SYNOPSIS
        Invokes the current configuration a virtual machine.
    .DESCRIPTION
        Invokes/sets a virtual machine configuration using the xVMHyperV DSC resource.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()]
        [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices,

        ## xVMProcessor options
        [Parameter()]
        [System.Collections.Hashtable] $ProcessorOption,

        ## xVMHardDiskDrive options
        [Parameter()]
        [System.Collections.Hashtable[]] $HardDiskDrive,

        ## xVMDvdDrive options
        [Parameter()]
        [System.Collections.Hashtable] $DvdDrive,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        ## Store additional options for when we have a VM
        $vmProcessorParams = $PSBoundParameters['ProcessorOption'];
        $vmDvdDriveParams = $PSBoundParameters['DvdDrive'];
        $vmHardDiskDriveParams = $PSBoundParameters['HardDiskDrive'];
        [ref] $null = $PSBoundParameters.Remove('ProcessorOption');
        [ref] $null = $PSBoundParameters.Remove('DvdDrive');
        [ref] $null = $PSBoundParameters.Remove('HardDiskDrive');

        ## Resolve the xVMHyperV resource parameters
        $vmHyperVParams = Get-LabVirtualMachineProperty @PSBoundParameters;
        WriteVerbose -Message ($localized.CreatingVMGeneration -f $vmHyperVParams.Generation);
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
        InvokeDscResource -ResourceName VM -Parameters $vmHyperVParams;

        if ($null -ne $vmProcessorParams) {

            ## Ensure we have the node's name
            $vmProcessorParams['VMName'] = $Name;
            WriteVerbose ($localized.SettingVMConfiguration -f 'VM processor', $Name);
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMProcessor -Prefix VMProcessor;
            InvokeDscResource -ResourceName VMProcessor -Parameters $vmProcessorParams;
        }

        if ($null -ne $vmDvdDriveParams) {

            ## Ensure we have the node's name
            $vmDvdDriveParams['VMName'] = $Name;
            WriteVerbose ($localized.SettingVMConfiguration -f 'VM DVD drive', $Name);
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMDvdDrive -Prefix VMDvdDrive;
            InvokeDscResource -ResourceName VMDvdDrive -Parameters $vmDvdDriveParams;
        }

        if ($null -ne $vmHardDiskDriveParams) {

            $setLabVirtualMachineHardDiskDriveParams = @{
                NodeName = $Name;
                VMGeneration = $vmHyperVParams.Generation;
                HardDiskDrive = $vmHardDiskDriveParams;
            }
            Set-LabVirtualMachineHardDiskDrive @setLabVirtualMachineHardDiskDriveParams;
        }

    } #end process
} #end function Set-LabVirtualMachine

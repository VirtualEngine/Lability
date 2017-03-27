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

        ## Store xVMProcessor and xVMDvdDrive options for after we have a VM
        $vmProcessorParams = $PSBoundParameters['ProcessorOption'];
        [ref] $null = $PSBoundParameters.Remove('ProcessorOption');
        $vmDvdDriveParams = $PSBoundParameters['DvdDrive'];
        [ref] $null = $PSBoundParameters.Remove('DvdDrive');

        ## Resolve the xVMHyperV resource parameters
        $vmHyperVParams = Get-LabVirtualMachineProperty @PSBoundParameters;
        WriteVerbose -Message ($localized.CreatingVMGeneration -f $vmHyperVParams.Generation);
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
        InvokeDscResource -ResourceName VM -Parameters $vmHyperVParams;

        if ($null -ne $vmProcessorParams) {

            ## Ensure we have the node's name
            $vmProcessorParams['VMName'] = $Name;
            WriteVerbose ($localized.SettingVMConfiguration -f 'VM processor', $Name);
            Write-Host $vmProcessorParams.Values -ForegroundColor Green;
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMProcessor -Prefix VMProcessor;
            InvokeDscResource -ResourceName VMProcessor -Parameters $vmProcessorParams;
        }

        if ($null -ne $vmDvdDriveParams) {

            ## Ensure we have the node's name
            $vmDvdDriveParams['VMName'] = $Name;
            WriteVerbose ($localized.SettingVMConfiguration -f 'VM DVD drive', $Name);
            Write-Host $vmDvdDriveParams.Values -ForegroundColor Green;
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMDvdDrive -Prefix VMDvdDrive;
            InvokeDscResource -ResourceName VMDvdDrive -Parameters $vmDvdDriveParams;
        }

    } #end process
} #end function Set-LabVirtualMachine

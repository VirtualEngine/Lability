function Test-LabVirtualMachine {
<#
    .SYNOPSIS
        Tests the current configuration a virtual machine.
    .DESCRIPTION
        Tests the current configuration a virtual machine using the xVMHyperV DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $vmHyperVParams = Get-LabVirtualMachineProperty @PSBoundParameters;
        Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;

        try {

            ## xVMHyperV\Test-TargetResource throws if the VHD doesn't exist?
            return (Test-LabDscResource -ResourceName VM -Parameters $vmHyperVParams -ErrorAction SilentlyContinue);
        }
        catch {

            return $false;
        }

    } #end process
} #end function Test-LabVirtualMachine

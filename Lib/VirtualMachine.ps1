function GetVirtualMachineProperties {
<#
    .SYNOPSIS
        Gets the DSC xVMHyperV properties.
#>
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()] [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices
    )
    process {
        ## Resolve the media to determine whether we require a Generation 1 or 2 VM..
        $labMedia = ResolveLabMedia -Id $Media;
        $labImage = Get-LabImage -Id $Media;
        if (-not $labImage) {
            ## Should only trigger during a Reset-VM where parent image is not available?!
            ## It will be downloaded during any NewLabVM calls..
            $labImage = @{ Generation = 'VHDX'; }
        }
        $labMediaArchitecture = $labMedia.Architecture;

        if (-not [System.String]::IsNullOrEmpty($labMedia.CustomData.PartitionStyle)) {
            ## The partition style has been overridden so use this
            if ($labMedia.CustomData.PartitionStyle -eq 'MBR') {
                $labMediaArchitecture = 'x86';
            }
            elseif ($labMedia.CustomData.PartitionStyle -eq 'GPT') {
                $labMediaArchitecture = 'x64';
            }
        }

        if ($labImage.Generation -eq 'VHD') {
            ## VHD files are only supported in G1 VMs
            $PSBoundParameters.Add('Generation', 1);
        }
        elseif ($labMediaArchitecture -eq 'x86') {
            $PSBoundParameters.Add('Generation', 1);
        }
        elseif ($labMediaArchitecture -eq 'x64') {
            $PSBoundParameters.Add('Generation', 2);
        }

        if ($null -eq $MACAddress) {
            [ref] $null = $PSBoundParameters.Remove('MACAddress');
        }

        if ($PSBoundParameters.ContainsKey('GuestIntegrationServices')) {
            [ref] $null = $PSBoundParameters.Add('EnableGuestService', $GuestIntegrationServices);
            [ref] $null = $PSBoundParameters.Remove('GuestIntegrationServices');
        }

        $vhdPath = ResolveLabVMDiskPath -Name $Name -Generation $labImage.Generation;

        [ref] $null = $PSBoundParameters.Remove('Media');
        [ref] $null = $PSBoundParameters.Add('VhdPath', $vhdPath);
        [ref] $null = $PSBoundParameters.Add('RestartIfNeeded', $true);

        return $PSBoundParameters;
    } #end process
} #end function GetVirtualMachineProperties

function TestLabVirtualMachine {
<#
    .SYNOPSIS
        Tests the current configuration a virtual machine.
    .DESCRIPTION
        Tests the current configuration a virtual machine using the xVMHyperV DSC resource.
#>
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()] [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices
    )
    process {
        $vmHyperVParams = GetVirtualMachineProperties @PSBoundParameters;
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
        if (-not (TestDscResource -ResourceName VM -Parameters $vmHyperVParams -ErrorAction SilentlyContinue)) {
            return $false;
        }
        return $true;
    } #end process
} #end function TestLabVirtualMachine

function SetLabVirtualMachine {
<#
    .SYNOPSIS
        Invokes the current configuration a virtual machine.
    .DESCRIPTION
        Invokes/sets a virtual machine configuration using the xVMHyperV DSC resource.
#>
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()] [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices
    )
    process {
        ## Resolve the xVMHyperV resource parameters
        $vmHyperVParams = GetVirtualMachineProperties @PSBoundParameters;
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
        InvokeDscResource -ResourceName VM -Parameters $vmHyperVParams # -ErrorAction SilentlyContinue;
    } #end process
} #end function SetLabVirtualMachine

function RemoveLabVirtualMachine {
<#
    .SYNOPSIS
        Removes the current configuration a virtual machine.
    .DESCRIPTION
        Invokes/sets a virtual machine configuration using the xVMHyperV DSC resource.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        [Parameter(Mandatory)]
        [System.UInt64] $StartupMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MinimumMemory,

        [Parameter(Mandatory)]
        [System.UInt64] $MaximumMemory,

        [Parameter(Mandatory)]
        [System.Int32] $ProcessorCount,

        [Parameter()] [AllowNull()]
        [System.String[]] $MACAddress,

        [Parameter()]
        [System.Boolean] $SecureBoot,

        [Parameter()]
        [System.Boolean] $GuestIntegrationServices
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name)) {
            ## Resolve the xVMHyperV resource parameters
            $vmHyperVParams = GetVirtualMachineProperties @PSBoundParameters;
            $vmHyperVParams['Ensure'] = 'Absent';
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
            InvokeDscResource -ResourceName VM -Parameters $vmHyperVParams -ErrorAction SilentlyContinue;
        }
    } #end process
} #end function RemoveLabVirtualMachine

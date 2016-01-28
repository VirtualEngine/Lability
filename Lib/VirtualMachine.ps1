function GetVirtualMachineProperties {
<#
    .SYNOPSIS
        Gets the DSC xVMHyperV properties.
#>
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $SwitchName,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Media,
        [Parameter(Mandatory)] [System.UInt64] $StartupMemory,
        [Parameter(Mandatory)] [System.UInt64] $MinimumMemory,
        [Parameter(Mandatory)] [System.UInt64] $MaximumMemory,
        [Parameter(Mandatory)] [System.Int32] $ProcessorCount,
        [Parameter()] [AllowNull()] [System.String[]] $MACAddress,
        [Parameter()] [System.Boolean] $SecureBoot
    )
    process {
        ## Resolve the media to determine whether we require a Generation 1 or 2 VM..
        $labMedia = Get-LabMedia -Id $Media;
        if ($labMedia.Architecture -eq 'x86') {
            $PSBoundParameters.Add('Generation', 1);
        }
        elseif ($labMedia.Architecture -eq 'x64') {
            $PSBoundParameters.Add('Generation', 2);
        }
        [ref] $null = $PSBoundParameters.Remove('Media');

        if ($null -eq $MACAddress) {
            [ref] $null = $PSBoundParameters.Remove('MACAddress');
        }

        $vhdPath = ResolveLabVMDiskPath -Name $Name;
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $SwitchName,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Media,
        [Parameter(Mandatory)] [System.UInt64] $StartupMemory,
        [Parameter(Mandatory)] [System.UInt64] $MinimumMemory,
        [Parameter(Mandatory)] [System.UInt64] $MaximumMemory,
        [Parameter(Mandatory)] [System.Int32] $ProcessorCount,
        [Parameter()] [AllowNull()] [System.String[]] $MACAddress,
        [Parameter()] [System.Boolean] $SecureBoot
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $SwitchName,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Media,
        [Parameter(Mandatory)] [System.UInt64] $StartupMemory,
        [Parameter(Mandatory)] [System.UInt64] $MinimumMemory,
        [Parameter(Mandatory)] [System.UInt64] $MaximumMemory,
        [Parameter(Mandatory)] [System.Int32] $ProcessorCount,
        [Parameter()] [AllowNull()] [System.String[]] $MACAddress,
        [Parameter()] [System.Boolean] $SecureBoot
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
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $SwitchName,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Media,
        [Parameter(Mandatory)] [System.UInt64] $StartupMemory,
        [Parameter(Mandatory)] [System.UInt64] $MinimumMemory,
        [Parameter(Mandatory)] [System.UInt64] $MaximumMemory,
        [Parameter(Mandatory)] [System.Int32] $ProcessorCount,
        [Parameter()] [AllowNull()] [System.String[]] $MACAddress,
        [Parameter()] [System.Boolean] $SecureBoot
    )
    process {
        ## Resolve the xVMHyperV resource parameters
        $vmHyperVParams = GetVirtualMachineProperties @PSBoundParameters;
        $vmHyperVParams['Ensure'] = 'Absent';
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
        InvokeDscResource -ResourceName VM -Parameters $vmHyperVParams -ErrorAction SilentlyContinue;
    } #end process
} #end function RemoveLabVirtualMachine

function ResolveLabVMDiskPath {
<#
    .SYNOPSIS
        Resolves the specified VM name to it's target VHDX path.
#>
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $vhdName = '{0}.vhdx' -f $Name;
        $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath $vhdName;
        return $vhdPath;
    } #end process
} #end function ResolaveLabVMVhdPath

function GetLabVMDisk {
<#
    .SYNOPSIS
        Retrieves lab virtual machine disk (VHDX) is present.
    .DESCRIPTION
        Gets a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $image = Get-LabImage -Id $Media;
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = 'VHDX';
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        GetDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end GetLbVMDisk

function TestLabVMDisk {
<#
    .SYNOPSIS
        Checks whether the lab virtual machine disk (VHDX) is present.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $image = Get-LabImage -Id $Media;
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = 'VHDX';
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        TestDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end function TestLabVMDisk

function SetLabVMDisk {
<#
    .SYNOPSIS
        Sets a lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $image = Get-LabImage -Id $Media -ErrorAction Stop;
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = 'VHDX';
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end SetLabVMDisk

function RemoveLabVMDisk {
<#
    .SYNOPSIS
        Removes lab VM disk file (VHDX) configuration.
    .DESCRIPTION
        Configures a VM disk configuration using the xVHD DSC resource.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $image = Get-LabImage -Id $Media -ErrorAction Stop;
        if ($image) {
            ## If the parent image isn't there, the differencing VHD won't be either
            $vhdPath = Join-Path -Path $hostDefaults.DifferencingVhdPath -ChildPath "$Name.vhdx";
            if (Test-Path -Path $vhdPath) {
                ## Only attempt to remove the differencing disk if it's there (and xVHD will throw)
                $vhd = @{
                    Name = $Name;
                    Path = $hostDefaults.DifferencingVhdPath;
                    ParentPath = $image.ImagePath;
                    Generation = 'VHDX';
                    Ensure = 'Absent';
                }
                ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
                [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;
            }
        }
    } #end process
} #end RemoveLabVMDisk

function ResetLabVMDisk {
<#
    .SYNOPSIS
        Removes and resets lab VM disk file (VHDX) configuration.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        RemoveLabVMSnapshot -Name $Name;
        RemoveLabVMDisk @PSBoundParameters;
        SetLabVMDisk @PSBoundParameters;
    } #end process
} #end function ResetLabVMDisk

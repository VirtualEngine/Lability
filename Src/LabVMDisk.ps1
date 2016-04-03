function ResolveLabVMDiskPath {
<#
    .SYNOPSIS
        Resolves the specified VM name to it's target VHDX path.
#>
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter()] [ValidateSet('VHD','VHDX')]
        [System.String] $Generation = 'VHDX'
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $vhdName = '{0}.{1}' -f $Name, $Generation.ToLower();
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
        ## VM/node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
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
            Generation = $image.Generation;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        GetDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end function GetLbVMDisk

function TestLabVMDisk {
<#
    .SYNOPSIS
        Checks whether the lab virtual machine disk (VHDX) is present.
#>
    [CmdletBinding()]
    param (
        ## VM/node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
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
            Generation = $image.Generation;
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
        ## VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
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
            Generation = $image.Generation;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end function SetLabVMDisk

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
} #end function RemoveLabVMDisk

function ResetLabVMDisk {
<#
    .SYNOPSIS
        Removes and resets lab VM disk file (VHDX) configuration.
#>
    [CmdletBinding()]
    param (
        ## VM/node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Media
    )
    process {
        RemoveLabVMSnapshot -Name $Name;
        RemoveLabVMDisk @PSBoundParameters;
        SetLabVMDisk @PSBoundParameters;
    } #end process
} #end function ResetLabVMDisk

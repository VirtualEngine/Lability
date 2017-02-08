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
} #end function ResolveLabVMDiskPath

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
            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;
        }
        else {
            $image = Get-LabImage -Id $Media;
        }
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = $image.Generation;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
        GetDscResource -ResourceName VHD -Parameters $vhd;
    } #end process
} #end function GetLabVMDisk

function TestLabVMDisk {
<#
    .SYNOPSIS
        Checks whether the lab virtual machine disk (VHDX) is present.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        $ConfigurationData,

        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {
            $image = Get-LabImage -Id $Media -ConfigurationData $ConfigurationData;
        }
        else {
            $image = Get-LabImage -Id $Media;
        }
        $vhd = @{
            Name = $Name;
            Path = $hostDefaults.DifferencingVhdPath;
            ParentPath = $image.ImagePath;
            Generation = $image.Generation;
        }
        if (-not $image) {
            ## This only occurs when a parent image is not available (#104).
            $vhd['MaximumSize'] = 136365211648; #127GB
            $vhd['Generation'] = 'VHDX';
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;

        $testDscResourceResult = TestDscResource -ResourceName VHD -Parameters $vhd;
        if ($Ensure -eq 'Absent') { return -not $testDscResourceResult; }
        else { return $testDscResourceResult; }
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
                    Ensure = 'Absent';
                }
                ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVHD -Prefix VHD;
                [ref] $null = InvokeDscResource -ResourceName VHD -Parameters $vhd;
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
        [System.String] $Media,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        RemoveLabVMSnapshot -Name $Name;
        RemoveLabVMDisk @PSBoundParameters;
        SetLabVMDisk @PSBoundParameters;
    } #end process
} #end function ResetLabVMDisk

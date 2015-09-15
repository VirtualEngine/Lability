function NewLabSwitch {
<#
    .SYNOPSIS
        Creates a new lab network switch object.
    .DESCRIPTION
        Permits validation of custom NonNodeData\VirtualEngineLab\Network entries.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateSet('Internal','External','Private')] [System.String] $Type,
        [Parameter()] [ValidateNotNull()] [System.String] $NetAdapterName,
        [Parameter()] [ValidateNotNull()] [System.Boolean] $AllowManagementOS = $false,
        [Parameter()] [ValidateSet('Present','Absent')] [System.String] $Ensure = 'Present'
    )
    begin {
        if (($Type -eq 'External') -and (-not $NetAdapterName)) {
            throw ($localized.MissingParameterError -f 'NetAdapterName');
        }
    } #end begin
    process {
        $newLabSwitch = @{
            Name = $Name;
            Type = $Type;
            NetAdapterName = $NetAdapterName;
            AllowManagementOS = $AllowManagementOS;
            Ensure = $Ensure;
        }
        if ($Type -ne 'External') {
            [ref] $null = $newLabSwitch.Remove('NetAdapterName');
            [ref] $null = $newLabSwitch.Remove('AllowManagementOS');
        }
        return $newLabSwitch;
    } #end process
} #end NewLabSwitch

function ResolveLabSwitch {
<#
    .SYNOPSIS
        Resolves the specified switch using configuration data.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $networkSwitch = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Network.Where({ $_.Name -eq $Name });
        if ($networkSwitch) {
            $networkHashtable = @{};
            foreach ($key in $networkSwitch.Keys) {
                [ref] $null = $networkHashtable.Add($key, $networkSwitch.$Key);
            }
            $networkSwitch = NewLabSwitch @networkHashtable;
        }
        else {
            ## Resolve to default host virtual switch?
            $vmDefaults = GetConfigurationData -Configuration VM;
            if ($Name -eq $vmDefaults.SwitchName) {
                $networkSwitch = @{ Name = $vmDefaults.SwitchName; Type = 'Internal'; }
            }
        }
        return $networkSwitch;
    } #end process
} #end function ResolveLabSwitch

function Get-LabSwitch {
<#
    .SYNOPSIS
        Retrieves the current configuration of a virtual network switch.
    .DESCRIPTION
        Gets a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    param (
        ## Switch Id/Name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (-not $networkSwitch) {
            throw ($localized.CannotLocateNetworkError -f $Name);
        }
    } #end begin
    process {
        $xVMSwitch = @{
            Name = $Name;
            Type = 'Internal';
        }
        if ($networkSwitch.Type) {
            $xVMSwitch['Type'] = $networkSwitch.Type;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        $switch = GetDscResource -ResourceName VMSwitch -Parameters $xVMSwitch;
        return [PSCustomObject] $switch;
    } #end process
} #end function GetLabSwitch

function TestLabSwitch {
<#
    .SYNOPSIS
        Tests the current configuration a virtual network switch.
    .DESCRIPTION
        Tests a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (-not $networkSwitch) {
            return $false;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        if (-not (TestDscResource -ResourceName VMSwitch -Parameters $networkSwitch)) {
            return $false;
        }
        
        return $true;
    } #end process
} #end function TestLabSwitch

function SetLabSwitch {
<#
    .SYNOPSIS
        Sets/invokes a virtual network switch configuration.
    .DESCRIPTION
        Sets/invokes a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    [CmdletBinding()]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (-not $networkSwitch) {
            throw ($localized.CannotLocateNetworkError -f $Name);
        }
    } #end begin
    process {
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        [ref] $null = InvokeDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
    } #end process
} #end function SetLabSwitch

function RemoveLabSwitch {
<#
    .SYNOPSIS
        Removes a virtual network switch configuration.
    .DESCRIPTION
        Deletes a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    [CmdletBinding()]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory)] [System.String] $Name,
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        $networkSwitch['Ensure'] = 'Absent';
        if (-not $networkSwitch) {
            throw ($localized.CannotLocateNetworkError -f $Name);
        }
    } #end begin
    process {
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        [ref] $null = InvokeDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
    } #end process
} #end function RemoveLabSwitch

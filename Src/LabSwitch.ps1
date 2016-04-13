function NewLabSwitch {
<#
    .SYNOPSIS
        Creates a new lab network switch object.
    .DESCRIPTION
        Permits validation of custom NonNodeData\Lability\Network entries.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Virtual switch name
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Virtual switch type
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateSet('Internal','External','Private')]
        [System.String] $Type,

        ## Physical network adapter name (for external switches)
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.String] $NetAdapterName,

        ## Share host access (for external virtual switches)
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.Boolean] $AllowManagementOS = $false,

        ## Virtual switch availability
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
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
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        $networkSwitch = $ConfigurationData.NonNodeData.$($labDefaults.ModuleName).Network.Where({ $_.Name -eq $Name });
        if ($networkSwitch) {
            $networkHashtable = @{};
            foreach ($key in $networkSwitch.Keys) {
                [ref] $null = $networkHashtable.Add($key, $networkSwitch.$Key);
            }
            $networkSwitch = NewLabSwitch @networkHashtable;
        }
        elseif (Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue) {
            ## Use an existing virtual switch with a matching name if one exists
            WriteWarning -Message ($localized.UsingExistingSwitchWarning -f $Name);
            $existingSwitch = Get-VMSwitch -Name $Name;
            $networkSwitch = @{
                Name = $existingSwitch.Name;
                Type = $existingSwitch.SwitchType;
                AllowManagementOS = $existingSwitch.AllowManagementOS;
                IsExisting = $true;
            }
            if ($existingSwitch.NetAdapterInterfaceDescription) {
                $networkSwitch['NetAdapterName'] = (Get-NetAdapter -InterfaceDescription $existingSwitch.NetAdapterInterfaceDescription).Name;
            }
        }
        else {
            ## Create an internal switch
            $networkSwitch = @{ Name = $Name; Type = 'Internal'; }
        }
        return $networkSwitch;
    } #end process
} #end function ResolveLabSwitch

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
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (($null -ne $networkSwitch.IsExisting) -and ($networkSwitch.IsExisting -eq $true)) {
            ## The existing virtual switch may be of a type not supported by the DSC resource.
            return $true;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        return TestDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
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
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (($null -eq $networkSwitch.IsExisting) -or ($networkSwitch.IsExisting -eq $false)) {
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
            [ref] $null = InvokeDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
        }
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
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (($null -eq $networkSwitch.IsExisting) -or ($networkSwitch.IsExisting -eq $false)) {
            $networkSwitch['Ensure'] = 'Absent';
            ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
            [ref] $null = InvokeDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
        }
    } #end process
} #end function RemoveLabSwitch

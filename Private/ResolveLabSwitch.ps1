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

}


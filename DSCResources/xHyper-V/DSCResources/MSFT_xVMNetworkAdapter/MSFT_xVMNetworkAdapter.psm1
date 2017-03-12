#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xVMNetworkAdapter.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xVMNetworkAdapter.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
.SYNOPSIS
    Gets MSFT_xVMNetworkAdapter resource current state.

.PARAMETER Id
    Specifies an unique identifier for the network adapter.

.PARAMETER Name
    Specifies a name for the network adapter that needs to be connected to a VM or management OS.

.PARAMETER SwitchName
    Specifies the name of the switch to which the new VM network adapter will be connected.

.PARAMETER VMName
    Specifies the name of the VM to which the network adapter will be connected.
    Specify VMName as ManagementOS if you wish to connect the adapter to host OS.
#>
Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory)]
        [String] $Id, 

        [Parameter(Mandatory)]
        [String] $Name,        

        [Parameter(Mandatory)]
        [String] $SwitchName,

        [Parameter(Mandatory)]
        [String] $VMName
    )

    $configuration = @{
        Id = $Id
        Name = $Name
        SwitchName = $SwitchName
        VMName = $VMName
    }

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName',$VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }

    Write-Verbose -Message $localizedData.GetVMNetAdapter
    $netAdapter = Get-VMNetworkAdapter @arguments -ErrorAction SilentlyContinue

    if ($netAdapter)
    {
        Write-Verbose -Message $localizedData.FoundVMNetAdapter
        if ($VMName -eq 'ManagementOS')
        {
            $configuration.Add('MacAddress', $netAdapter.MacAddress)
            $configuration.Add('DynamicMacAddress', $false)
        }
        elseif ($netAdapter.VMName)
        {
            $configuration.Add('MacAddress', $netAdapter.MacAddress)   
            $configuration.Add('DynamicMacAddress', $netAdapter.DynamicMacAddressEnabled)
        }
        $configuration.Add('Ensure','Present')
    }
    else
    {
        Write-Verbose -Message $localizedData.NoVMNetAdapterFound
        $configuration.Add('Ensure','Absent')
    }

    return $configuration
}

<#
.SYNOPSIS
    Sets MSFT_xVMNetworkAdapter resource state.

.PARAMETER Id
    Specifies an unique identifier for the network adapter.

.PARAMETER Name
    Specifies a name for the network adapter that needs to be connected to a VM or management OS.

.PARAMETER SwitchName
    Specifies the name of the switch to which the new VM network adapter will be connected.

.PARAMETER VMName
    Specifies the name of the VM to which the network adapter will be connected.
    Specify VMName as ManagementOS if you wish to connect the adapter to host OS.

.PARAMETER MacAddress
    Specifies the MAC address for the network adapter. This is not applicable if VMName
    is set to ManagementOS. Use this parameter to specify a static MAC address.

.PARAMETER Ensure
    Specifies if the network adapter should be Present or Absent.
#>
Function Set-TargetResource
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [String] $Id, 

        [Parameter(Mandatory)]
        [String] $Name,

        [Parameter(Mandatory)]
        [String] $SwitchName,

        [Parameter(Mandatory)]
        [String] $VMName,

        [Parameter()]
        [String] $MacAddress,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure='Present'
    )

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName',$VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }
    
    Write-Verbose -Message $localizedData.GetVMNetAdapter
    $netAdapterExists = Get-VMNetworkAdapter @arguments -ErrorAction SilentlyContinue
    
    if ($Ensure -eq 'Present')
    {
        if ($netAdapterExists)
        {
            Write-Verbose -Message $localizedData.FoundVMNetAdapter
            if (($VMName -ne 'ManagementOS'))
            {
                if ($MacAddress)
                {
                    if ($netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $localizedData.EnableStaticMacAddress
                        $updateMacAddress = $true
                    }
                    elseif ($MacAddress -ne $netAdapterExists.StaicMacAddress)
                    {
                        Write-Verbose -Message $localizedData.EnableStaticMacAddress
                        $updateMacAddress = $true
                    }
                }
                else
                {
                    if (-not $netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $localizedData.EnableDynamicMacAddress
                        $updateMacAddress = $true
                    }
                }
                
                if ($netAdapterExists.SwitchName -ne $SwitchName)
                {
                    Write-Verbose -Message $localizedData.PerformSwitchConnect
                    Connect-VMNetworkAdapter -VMNetworkAdapter $netAdapterExists -SwitchName $SwitchName -ErrorAction Stop -Verbose
                }
                
                if (($updateMacAddress))
                {
                    Write-Verbose -Message $localizedData.PerformVMNetModify

                    $setArguments = @{ }
                    $setArguments.Add('VMNetworkAdapter',$netAdapterExists)
                    if ($MacAddress)
                    {
                        $setArguments.Add('StaticMacAddress',$MacAddress)
                    }
                    else
                    {
                        $setArguments.Add('DynamicMacAddress', $true)
                    }
                    Set-VMNetworkAdapter @setArguments -ErrorAction Stop
                }
            }
        }
        else
        {
            if ($VMName -ne 'ManagementOS')
            {
                if (-not $MacAddress)
                {
                    $arguments.Add('DynamicMacAddress',$true)
                }
                else
                {
                    $arguments.Add('StaticMacAddress',$MacAddress)
                }
                $arguments.Add('SwitchName',$SwitchName)
            }
            Write-Verbose -Message $localizedData.AddVMNetAdapter
            Add-VMNetworkAdapter @arguments -ErrorAction Stop
        }
    }
    else
    {
        Write-Verbose -Message $localizedData.RemoveVMNetAdapter
        Remove-VMNetworkAdapter @arguments -ErrorAction Stop
    }
}

<#
.SYNOPSIS
    Tests if MSFT_xVMNetworkAdapter resource state is indeed desired state or not.

.PARAMETER Id
    Specifies an unique identifier for the network adapter.

.PARAMETER Name
    Specifies a name for the network adapter that needs to be connected to a VM or management OS.

.PARAMETER SwitchName
    Specifies the name of the switch to which the new VM network adapter will be connected.

.PARAMETER VMName
    Specifies the name of the VM to which the network adapter will be connected.
    Specify VMName as ManagementOS if you wish to connect the adapter to host OS.

.PARAMETER MacAddress
    Specifies the MAC address for the network adapter. This is not applicable if VMName
    is set to ManagementOS. Use this parameter to specify a static MAC address.

.PARAMETER Ensure
    Specifies if the network adapter should be Present or Absent.
#>
Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [String] $Id, 
                
        [Parameter(Mandatory)]
        [String] $Name,

        [Parameter(Mandatory)]
        [String] $SwitchName,

        [Parameter(Mandatory)]
        [String] $VMName,

        [Parameter()]
        [String] $MacAddress,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure='Present'
    )

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName',$VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }
    
    Write-Verbose -Message $localizedData.GetVMNetAdapter
    $netAdapterExists = Get-VMNetworkAdapter @arguments -ErrorAction SilentlyContinue

    if ($Ensure -eq 'Present')
    {
        if ($netAdapterExists)
        {
            if ($VMName -ne 'ManagementOS')
            {
                if ($MacAddress)
                {
                    if ($netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $localizedData.EnableStaticMacAddress
                        return $false
                    }
                    elseif ($netAdapterExists.MacAddress -ne $MacAddress)
                    {
                        Write-Verbose -Message $localizedData.StaticAddressDoesNotMatch
                        return $false
                    }
                }
                else
                {
                    if (-not $netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $localizedData.EnableDynamicMacAddress
                        return $false
                    }
                } 
                
                if ($netAdapterExists.SwitchName -ne $SwitchName)
                {
                    Write-Verbose -Message $localizedData.SwitchIsDifferent
                    return $false
                } 
                else
                {
                    Write-Verbose -Message $localizedData.VMNetAdapterExistsNoActionNeeded
                    return $true
                }
            }
            else
            {
                Write-Verbose -Message $localizedData.VMNetAdapterExistsNoActionNeeded
                return $true
            }
        } 
        else
        {
            Write-Verbose -Message $localizedData.VMNetAdapterDoesNotExistShouldAdd
            return $false
        }
    }
    else
    {
        if ($netAdapterExists)
        {
            Write-Verbose -Message $localizedData.VMNetAdapterExistsShouldRemove
            return $false
        }
        else
        {
            Write-Verbose -Message $localizedData.VMNetAdapterDoesNotExistNoActionNeeded
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource

$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/DscResource.Common'

Import-Module -Name $script:dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

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

.PARAMETER IpAddress
    Specifies the IpAddress information for the network adapter.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SwitchName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )

    $configuration = @{
        Id         = $Id
        Name       = $Name
        SwitchName = $SwitchName
        VMName     = $VMName
    }

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName', $VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }

    Write-Verbose -Message $script:localizedData.GetVMNetAdapter
    $netAdapter = Get-VMNetworkAdapter @arguments -ErrorAction SilentlyContinue

    if ($netAdapter)
    {
        Write-Verbose -Message $script:localizedData.FoundVMNetAdapter
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

        $networkInfo = Get-NetworkInformation -VMName $VMName -Name $Name
        if ($networkInfo)
        {
            $item = New-CimInstance -ClassName MSFT_xNetworkSettings -Property $networkInfo -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
            $configuration.Add('NetworkSetting', $item)
        }

        $configuration.Add('Ensure', 'Present')

        Write-Verbose -Message $script:localizedData.GetVMNetAdapterVlan
        $netAdapterVlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $netAdapter
        if ($netAdapterVlan.OperationMode -ne 'Untagged')
        {
            $configuration.Add('VlanId', $netAdapterVlan.AccessVlanId)
        }
    }
    else
    {
        Write-Verbose -Message $script:localizedData.NoVMNetAdapterFound
        $configuration.Add('Ensure', 'Absent')
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

.PARAMETER IpAddress
    Specifies the IpAddress information for the network adapter.

.PARAMETER VlanId
    Specifies the Vlan Id for the network adapter.

.PARAMETER Ensure
    Specifies if the network adapter should be Present or Absent.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SwitchName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter()]
        [System.String]
        $MacAddress,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $NetworkSetting,

        [Parameter()]
        [System.String]
        $VlanId,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName', $VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }

    Write-Verbose -Message $script:localizedData.GetVMNetAdapter
    $netAdapterExists = Get-VMNetworkAdapter @arguments -ErrorAction SilentlyContinue

    if ($Ensure -eq 'Present')
    {
        if ($netAdapterExists)
        {
            Write-Verbose -Message $script:localizedData.FoundVMNetAdapter
            if (($VMName -ne 'ManagementOS'))
            {
                if ($MacAddress)
                {
                    if ($netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $script:localizedData.EnableStaticMacAddress
                        $updateMacAddress = $true
                    }
                    elseif ($MacAddress -ne $netAdapterExists.StaicMacAddress)
                    {
                        Write-Verbose -Message $script:localizedData.EnableStaticMacAddress
                        $updateMacAddress = $true
                    }
                }
                else
                {
                    if (-not $netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $script:localizedData.EnableDynamicMacAddress
                        $updateMacAddress = $true
                    }
                }

                if ($netAdapterExists.SwitchName -ne $SwitchName)
                {
                    Write-Verbose -Message $script:localizedData.PerformSwitchConnect
                    Connect-VMNetworkAdapter -VMNetworkAdapter $netAdapterExists -SwitchName $SwitchName -ErrorAction Stop -Verbose
                }

                if (($updateMacAddress))
                {
                    Write-Verbose -Message $script:localizedData.PerformVMNetModify

                    $setArguments = @{ }
                    $setArguments.Add('VMNetworkAdapter', $netAdapterExists)
                    if ($MacAddress)
                    {
                        $setArguments.Add('StaticMacAddress', $MacAddress)
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
                    $arguments.Add('DynamicMacAddress', $true)
                }
                else
                {
                    $arguments.Add('StaticMacAddress', $MacAddress)
                }
                $arguments.Add('SwitchName', $SwitchName)
            }
            Write-Verbose -Message $script:localizedData.AddVMNetAdapter
            $netAdapterExists = Add-VMNetworkAdapter @arguments -Passthru -ErrorAction Stop
        }

        if ($VmName -ne 'ManagementOS')
        {
            $networkInfo = Get-NetworkInformation -VMName $VMName -Name $Name
            if (-not $NetworkSetting)
            {
                if ($networkInfo)
                {
                    Write-Verbose -Message $script:localizedData.EnableDhcp
                    Set-NetworkInformation -VMName $VMName -Name $Name -Dhcp
                }
            }
            else
            {
                $parameters = @{ }
                if ($ipAddress = $NetworkSetting.CimInstanceProperties['IpAddress'].Value)
                {
                    if (-not $ipAddress)
                    {
                        throw $script:localizedData.MissingIPAndSubnet
                    }
                    $parameters.Add('IPAddress', $ipAddress)
                }
                if ($subnet = $NetworkSetting.CimInstanceProperties['Subnet'].Value)
                {
                    if (-not $subnet)
                    {
                        throw $script:localizedData.MissingIPAndSubnet
                    }
                    $parameters.Add('Subnet', $subnet)
                }
                if ($defaultGateway = $NetworkSetting.CimInstanceProperties['DefaultGateway'].Value)
                {
                    $parameters.Add('DefaultGateway', $defaultGateway)
                }
                if ($dnsServer = $NetworkSetting.CimInstanceProperties['DnsServer'].Value)
                {
                    $parameters.Add('DnsServer', $dnsServer)
                }

                Set-NetworkInformation -VMName $VMName -Name $Name @parameters
            }

            Write-Verbose -Message $script:localizedData.GetVMNetAdapterVlan
            $netAdapterVlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $netAdapterExists
            if ($netAdapterVlan)
            {
                if ($VlanId)
                {
                    $setVlan = $true
                }
                else
                {
                    Write-Verbose -Message $script:localizedData.RemovingVlanTag
                    Set-VMNetworkAdapterVlan -VMNetworkAdapter $netAdapterExists -Untagged
                }
            }
            elseif ($VlanId)
            {
                $setVlan = $true
            }

            if ($setVlan)
            {
                Write-Verbose -Message $script:localizedData.SettingVlan
                Set-VMNetworkAdapterVlan -VMNetworkAdapter $netAdapterExists -Access -VlanId $VlanId
            }
        }
    }
    else
    {
        Write-Verbose -Message $script:localizedData.RemoveVMNetAdapter
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

.PARAMETER IpAddress
    Specifies the IpAddress information for the network adapter.

.PARAMETER VlanId
    Specifies the Vlan Id for the network adapter.

.PARAMETER Ensure
    Specifies if the network adapter should be Present or Absent.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SwitchName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter()]
        [System.String]
        $MacAddress,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $NetworkSetting,

        [Parameter()]
        [System.String]
        $VlanId,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $arguments = @{
        Name = $Name
    }

    if ($VMName -ne 'ManagementOS')
    {
        $arguments.Add('VMName', $VMName)
    }
    else
    {
        $arguments.Add('ManagementOS', $true)
        $arguments.Add('SwitchName', $SwitchName)
    }

    Write-Verbose -Message $script:localizedData.GetVMNetAdapter
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
                        Write-Verbose -Message $script:localizedData.EnableStaticMacAddress
                        return $false
                    }
                    elseif ($netAdapterExists.MacAddress -ne $MacAddress)
                    {
                        Write-Verbose -Message $script:localizedData.StaticAddressDoesNotMatch
                        return $false
                    }
                }
                else
                {
                    if (-not $netAdapterExists.DynamicMacAddressEnabled)
                    {
                        Write-Verbose -Message $script:localizedData.EnableDynamicMacAddress
                        return $false
                    }
                }

                $networkInfo = Get-NetworkInformation -VMName $VMName -Name $Name
                if (-not $NetworkSetting)
                {
                    if ($networkInfo)
                    {
                        Write-Verbose -Message $script:localizedData.NotDhcp
                        return $false
                    }
                }
                else
                {
                    if (-not $networkInfo)
                    {
                        Write-Verbose -Message $script:localizedData.Dhcp
                        return $false
                    }
                    else
                    {
                        $ipAddress = $NetworkSetting.CimInstanceProperties['IpAddress'].Value
                        $subnet = $NetworkSetting.CimInstanceProperties['Subnet'].Value
                        $defaultGateway = $NetworkSetting.CimInstanceProperties['DefaultGateway'].Value
                        $dnsServer = $NetworkSetting.CimInstanceProperties['DnsServer'].Value

                        if (-not $IpAddress -or -not $subnet)
                        {
                            throw $script:localizedData.MissingIPAndSubnet
                        }

                        if ($ipAddress -and -not $networkInfo.IPAddress.Split(',').Contains($ipAddress))
                        {
                            Write-Verbose -Message $script:localizedData.IPAddressNotConfigured
                            return $false
                        }

                        if ($defaultGateway -and -not $networkInfo.DefaultGateway.Split(',').Contains($defaultGateway))
                        {
                            Write-Verbose -Message $script:localizedData.GatewayNotConfigured
                            return $false
                        }

                        if ($dnsServer -and -not $networkInfo.DNSServer.Split(',').Contains($dnsServer))
                        {
                            Write-Verbose -Message $script:localizedData.DNSServerNotConfigured
                            return $false
                        }
                    }
                }

                Write-Verbose -Message $script:localizedData.GetVMNetAdapterVlan
                $netAdapterVlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $netAdapterExists
                if ($netAdapterVlan)
                {
                    if ($netAdapterVlan.OperationMode -eq 'Untagged')
                    {
                        if ($VlanId)
                        {
                            Write-Verbose -Message $script:localizedData.VlanNotUntagged
                            return $false
                        }
                    }
                    else
                    {
                        if ($VlanId)
                        {
                            if ($netAdapterVlan.AccessVlanId -ne $VlanId)
                            {
                                Write-Verbose -Message $script:localizedData.VlanDoesNotMatch
                                return $false
                            }
                        }
                        else
                        {
                            Write-Verbose -Message $script:localizedData.VlanShouldntBeTagged
                            return $false
                        }
                    }
                }
                elseif ($VlanId)
                {
                    Write-Verbose -Message $script:localizedData.VlanNotUntagged
                    return $false
                }

                if ($netAdapterExists.SwitchName -ne $SwitchName)
                {
                    Write-Verbose -Message $script:localizedData.SwitchIsDifferent
                    return $false
                }
                else
                {
                    Write-Verbose -Message $script:localizedData.VMNetAdapterExistsNoActionNeeded
                    return $true
                }

            }
            else
            {
                Write-Verbose -Message $script:localizedData.VMNetAdapterExistsNoActionNeeded
                return $true
            }
        }
        else
        {
            Write-Verbose -Message $script:localizedData.VMNetAdapterDoesNotExistShouldAdd
            return $false
        }
    }
    else
    {
        if ($netAdapterExists)
        {
            Write-Verbose -Message $script:localizedData.VMNetAdapterExistsShouldRemove
            return $false
        }
        else
        {
            Write-Verbose -Message $script:localizedData.VMNetAdapterDoesNotExistNoActionNeeded
            return $true
        }
    }
}

function Get-NetworkInformation
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $vm = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' | Where-Object { $_.ElementName -ieq "$VmName" }
    $vmSettings = $vm.GetRelated('Msvm_VirtualSystemSettingData') | Where-Object { $_.VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized' }
    $vmNetAdapter = $vmSettings.GetRelated('Msvm_SyntheticEthernetPortSettingData') | Where-Object { $_.ElementName -ieq "$Name" }
    $networkSettings = $vmNetAdapter.GetRelated('Msvm_GuestNetworkAdapterConfiguration')

    if ($networkSettings.DHCPEnabled)
    {
        return $null
    }
    else
    {
        return  @{
            IpAddress      = $networkSettings.IPAddresses -join ','
            Subnet         = $networkSettings.Subnets -join ','
            DefaultGateway = $networkSettings.DefaultGateways -join ','
            DnsServer      = $networkSettings.DNSServers -join ','
        }
    }

}

function Set-NetworkInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(ParameterSetName = 'Dhcp')]
        [switch]
        $Dhcp,

        [Parameter(Mandatory = $true, ParameterSetName = 'Static')]
        [System.String]
        $IPAddress,

        [Parameter(Mandatory = $true, ParameterSetName = 'Static')]
        [System.String]
        $Subnet,

        [Parameter(ParameterSetName = 'Static')]
        [System.String]
        $DefaultGateway,

        [Parameter(ParameterSetName = 'Static')]
        [System.String]
        $DnsServer
    )

    $vm = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' | Where-Object { $_.ElementName -ieq "$VmName" }
    $vmSettings = $vm.GetRelated('Msvm_VirtualSystemSettingData') | Where-Object { $_.VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized' }
    $vmNetAdapter = $vmSettings.GetRelated('Msvm_SyntheticEthernetPortSettingData') | Where-Object { $_.ElementName -ieq $Name }
    $networkSettings = $vmNetAdapter.GetRelated('Msvm_GuestNetworkAdapterConfiguration') | Select-Object -First 1

    switch ($PSCmdlet.ParameterSetName)
    {
        'Dhcp'
        {
            $networkSettings.DHCPEnabled = $true
            $networkSettings.IPAddresses = @()
            $networkSettings.Subnets = @()
            $networkSettings.DefaultGateways = @()
            $networkSettings.DNSServers = @()
        }

        'Static'
        {
            $networkSettings.IPAddresses = $IPAddress
            $networkSettings.Subnets = $Subnet

            if ($DefaultGateway)
            {
                $networkSettings.DefaultGateways = $DefaultGateway
            }

            if ($DnsServer)
            {
                $networkSettings.DNSServers = $DNSServer
            }

            $networkSettings.DHCPEnabled = $false
        }
    }

    $networkSettings.ProtocolIFType = 4096

    $service = Get-WmiObject -Class 'Msvm_VirtualSystemManagementService' -Namespace 'root\virtualization\v2'
    $setIP = $service.SetGuestNetworkAdapterConfiguration($vm, $networkSettings.GetText(1))

    if ($setIP.ReturnValue -eq 4096)
    {
        $job = [WMI]$setIP.job

        while ($job.JobState -eq 3 -or $job.JobState -eq 4)
        {
            Start-Sleep 1
            $job = [WMI]$setIP.job
        }

        if ($job.JobState -ne 7)
        {
            throw $job.GetError().Error
        }
    }
}

Export-ModuleMember -Function *-TargetResource

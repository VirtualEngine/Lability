#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -Filename MSFT_xVMHost.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    # fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -Filename MSFT_xVMHost.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

# Import the common HyperV functions
Import-Module -Name ( Join-Path `
        -Path (Split-Path -Path $PSScriptRoot -Parent) `
        -ChildPath '\HyperVCommon\HyperVCommon.psm1' )

<#
.SYNOPSIS
    Gets MSFT_xVMHost resource current state.

.PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance
    )

    Assert-Module -Name 'Hyper-V'

    Write-Verbose -Message $localizedData.QueryingVMHost
    $vmHost = Get-VMHost

    # Convert the current TimeSpan into minutes
    $convertFromTimeSpanParams = @{
        TimeSpan = $vmHost.ResourceMeteringSaveInterval
        TimeSpanType = 'Minutes'
    }
    $resourceMeteringSaveInterval = ConvertFrom-TimeSpan @convertFromTimeSpanParams

    $configuration = @{
        IsSingleInstance = $IsSingleInstance
        EnableEnhancedSessionMode = $vmHost.EnableEnhancedSessionMode
        FibreChannelWwnn = $vmHost.FibreChannelWwnn
        FibreChannelWwpnMaximum = $vmHost.FibreChannelWwpnMaximum
        FibreChannelWwpnMinimum = $vmHost.FibreChannelWwpnMinimum
        MacAddressMaximum = $vmHost.MacAddressMaximum
        MacAddressMinimum = $vmHost.MacAddressMinimum
        MaximumStorageMigrations = $vmHost.MaximumStorageMigrations
        MaximumVirtualMachineMigrations = $vmHost.MaximumVirtualMachineMigrations
        NumaSpanningEnabled = $vmHost.NumaSpanningEnabled
        ResourceMeteringSaveIntervalMinute = $resourceMeteringSaveInterval
        UseAnyNetworkForMigration = $vmHost.UseAnyNetworkForMigration
        VirtualHardDiskPath = $vmHost.VirtualHardDiskPath
        VirtualMachineMigrationAuthenticationType = $vmHost.VirtualMachineMigrationAuthenticationType
        VirtualMachineMigrationPerformanceOption = $vmHost.VirtualMachineMigrationPerformanceOption
        VirtualMachinePath = $vmHost.VirtualMachinePath
        VirtualMachineMigrationEnabled = $vmHost.VirtualMachineMigrationEnabled
    }

    return $configuration
}

<#
.SYNOPSIS
    Tests if MSFT_xVMHost resource state is in the desired state or not.

.PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.

.PARAMETER EnableEnhancedSessionMode
    Indicates whether users can use enhanced mode when they connect to virtual machines on this
    server by using Virtual Machine Connection.

.PARAMETER FibreChannelWwnn
    Specifies the default value of the World Wide Node Name on the Hyper-V host.

.PARAMETER FibreChannelWwpnMaximum
    Specifies the maximum value that can be used to generate World Wide Port Names on the Hyper-V
    host. Use with the FibreChannelWwpnMinimum parameter to establish a range of WWPNs that the
    specified Hyper-V host can assign to virtual Fibre Channel adapters.

.PARAMETER FibreChannelWwpnMinimum
   Specifies the minimum value that can be used to generate the World Wide Port Names on the
   Hyper-V host. Use with the FibreChannelWwpnMaximum parameter to establish a range of WWPNs that
   the specified Hyper-V host can assign to virtual Fibre Channel adapters.

.PARAMETER MacAddressMaximum
    Specifies the maximum MAC address using a valid hexadecimal value. Use with the
    MacAddressMinimum parameter to establish a range of MAC addresses that the specified Hyper-V
    host can assign to virtual machines configured to receive dynamic MAC addresses.

.PARAMETER MacAddressMinimum
    Specifies the minimum MAC address using a valid hexadecimal value. Use with the
    MacAddressMaximum parameter to establish a range of MAC addresses that the specified Hyper-V
    host can assign to virtual machines configured to receive dynamic MAC addresses.

.PARAMETER MaximumStorageMigrations
    Specifies the maximum number of storage migrations that can be performed at the same time on
    the Hyper-V host.

.PARAMETER MaximumVirtualMachineMigrations
    Specifies the maximum number of live migrations that can be performed at the same time on the
    Hyper-V host.

.PARAMETER NumaSpanningEnabled
    Specifies whether virtual machines on the Hyper-V host can use resources from more than one
    NUMA node.

.PARAMETER ResourceMeteringSaveIntervalMinute
    Specifies how often the Hyper-V host saves the data that tracks resource usage. The range is a
    minimum of 60 minutes to a maximum 1440 minutes (24 hours).

.PARAMETER UseAnyNetworkForMigration
    Specifies how networks are selected for incoming live migration traffic. If set to $True, any
    available network on the host can be used for this traffic. If set to $False, incoming live
    migration traffic is transmitted only on the networks specified in the MigrationNetworks
    property of the host.

.PARAMETER VirtualHardDiskPath
    Specifies the default folder to store virtual hard disks on the Hyper-V host.

.PARAMETER VirtualMachineMigrationAuthenticationType
    Specifies the type of authentication to be used for live migrations. The acceptable values for
    this parameter are 'Kerberos' and 'CredSSP'.

.PARAMETER VirtualMachineMigrationPerformanceOption
    Specifies the performance option to use for live migration. The acceptable values for this
    parameter are 'TCPIP', 'Compression' and 'SMB'.

.PARAMETER VirtualMachinePath
    Specifies the default folder to store virtual machine configuration files on the Hyper-V host.

.PARAMETER VirtualMachineMigrationEnabled
    Indicates whether Live Migration should be enabled or disabled on the Hyper-V host.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $EnableEnhancedSessionMode,

        [Parameter()]
        [System.String]
        $FibreChannelWwnn,

        [Parameter()]
        [System.String]
        $FibreChannelWwpnMaximum,

        [Parameter()]
        [System.String]
        $FibreChannelWwpnMinimum,

        [Parameter()]
        [System.String]
        $MacAddressMaximum,

        [Parameter()]
        [System.String]
        $MacAddressMinimum,

        [Parameter()]
        [System.UInt32]
        $MaximumStorageMigrations,

        [Parameter()]
        [System.UInt32]
        $MaximumVirtualMachineMigrations,

        [Parameter()]
        [System.Boolean]
        $NumaSpanningEnabled,

        [Parameter()]
        [System.UInt32]
        $ResourceMeteringSaveIntervalMinute,

        [Parameter()]
        [System.Boolean]
        $UseAnyNetworkForMigration,

        [Parameter()]
        [System.String]
        $VirtualHardDiskPath,

        [Parameter()]
        [ValidateSet('Kerberos', 'CredSSP')]
        [System.String]
        $VirtualMachineMigrationAuthenticationType,

        [Parameter()]
        [ValidateSet('TCPIP', 'Compression', 'SMB')]
        [System.String]
        $VirtualMachineMigrationPerformanceOption,

        [Parameter()]
        [System.String]
        $VirtualMachinePath,

        [Parameter()]
        [System.Boolean]
        $VirtualMachineMigrationEnabled
    )

    Assert-Module -Name 'Hyper-V'

    $targetResource = Get-TargetResource -IsSingleInstance $IsSingleInstance
    $isTargetResourceCompliant = $true

    foreach ($parameter in $PSBoundParameters.GetEnumerator())
    {
        if (($targetResource.ContainsKey($parameter.Key)) -and
            ($parameter.Value -ne $targetResource[$parameter.Key]))
        {
            $isTargetResourceCompliant = $false
            Write-Verbose -Message ($localizedData.PropertyMismatch -f $parameter.Key,
                $parameter.Value, $targetResource[$parameter.Key])
        }
    }

    if ($isTargetResourceCompliant)
    {
        Write-Verbose -Message $localizedData.VMHostInDesiredState
    }
    else
    {
        Write-Verbose -Message $localizedData.VMHostNotInDesiredState
    }

    return $isTargetResourceCompliant
} #end function

<#
.SYNOPSIS
    Configures MSFT_xVMHost resource state.

.PARAMETER IsSingleInstance
    Specifies the resource is a single instance, the value must be 'Yes'.

.PARAMETER EnableEnhancedSessionMode
    Indicates whether users can use enhanced mode when they connect to virtual machines on this
    server by using Virtual Machine Connection.

.PARAMETER FibreChannelWwnn
    Specifies the default value of the World Wide Node Name on the Hyper-V host.

.PARAMETER FibreChannelWwpnMaximum
    Specifies the maximum value that can be used to generate World Wide Port Names on the Hyper-V
    host. Use with the FibreChannelWwpnMinimum parameter to establish a range of WWPNs that the
    specified Hyper-V host can assign to virtual Fibre Channel adapters.

.PARAMETER FibreChannelWwpnMinimum
   Specifies the minimum value that can be used to generate the World Wide Port Names on the
   Hyper-V host. Use with the FibreChannelWwpnMaximum parameter to establish a range of WWPNs that
   the specified Hyper-V host can assign to virtual Fibre Channel adapters.

.PARAMETER MacAddressMaximum
    Specifies the maximum MAC address using a valid hexadecimal value. Use with the
    MacAddressMinimum parameter to establish a range of MAC addresses that the specified Hyper-V
    host can assign to virtual machines configured to receive dynamic MAC addresses.

.PARAMETER MacAddressMinimum
    Specifies the minimum MAC address using a valid hexadecimal value. Use with the
    MacAddressMaximum parameter to establish a range of MAC addresses that the specified Hyper-V
    host can assign to virtual machines configured to receive dynamic MAC addresses.

.PARAMETER MaximumStorageMigrations
    Specifies the maximum number of storage migrations that can be performed at the same time on
    the Hyper-V host.

.PARAMETER MaximumVirtualMachineMigrations
    Specifies the maximum number of live migrations that can be performed at the same time on the
    Hyper-V host.

.PARAMETER NumaSpanningEnabled
    Specifies whether virtual machines on the Hyper-V host can use resources from more than one
    NUMA node.

.PARAMETER ResourceMeteringSaveIntervalMinute
    Specifies how often the Hyper-V host saves the data that tracks resource usage. The range is a
    minimum of 60 minutes to a maximum 1440 minutes (24 hours).

.PARAMETER UseAnyNetworkForMigration
    Specifies how networks are selected for incoming live migration traffic. If set to $True, any
    available network on the host can be used for this traffic. If set to $False, incoming live
    migration traffic is transmitted only on the networks specified in the MigrationNetworks
    property of the host.

.PARAMETER VirtualHardDiskPath
    Specifies the default folder to store virtual hard disks on the Hyper-V host.

.PARAMETER VirtualMachineMigrationAuthenticationType
    Specifies the type of authentication to be used for live migrations. The acceptable values for
    this parameter are 'Kerberos' and 'CredSSP'.

.PARAMETER VirtualMachineMigrationPerformanceOption
    Specifies the performance option to use for live migration. The acceptable values for this
    parameter are 'TCPIP', 'Compression' and 'SMB'.

.PARAMETER VirtualMachinePath
    Specifies the default folder to store virtual machine configuration files on the Hyper-V host.

.PARAMETER VirtualMachineMigrationEnabled
    Indicates whether Live Migration should be enabled or disabled on the Hyper-V host.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $EnableEnhancedSessionMode,

        [Parameter()]
        [System.String]
        $FibreChannelWwnn,

        [Parameter()]
        [System.String]
        $FibreChannelWwpnMaximum,

        [Parameter()]
        [System.String]
        $FibreChannelWwpnMinimum,

        [Parameter()]
        [System.String]
        $MacAddressMaximum,

        [Parameter()]
        [System.String]
        $MacAddressMinimum,

        [Parameter()]
        [System.UInt32]
        $MaximumStorageMigrations,

        [Parameter()]
        [System.UInt32]
        $MaximumVirtualMachineMigrations,

        [Parameter()]
        [System.Boolean]
        $NumaSpanningEnabled,

        [Parameter()]
        [System.UInt32]
        $ResourceMeteringSaveIntervalMinute,

        [Parameter()]
        [System.Boolean]
        $UseAnyNetworkForMigration,

        [Parameter()]
        [System.String]
        $VirtualHardDiskPath,

        [Parameter()]
        [ValidateSet('Kerberos', 'CredSSP')]
        [System.String]
        $VirtualMachineMigrationAuthenticationType,

        [Parameter()]
        [ValidateSet('TCPIP', 'Compression', 'SMB')]
        [System.String]
        $VirtualMachineMigrationPerformanceOption,

        [Parameter()]
        [System.String]
        $VirtualMachinePath,

        [Parameter()]
        [System.Boolean]
        $VirtualMachineMigrationEnabled
    )

    Assert-Module -Name 'Hyper-V'

    $null = $PSBoundParameters.Remove('IsSingleInstance')

    if ($PSBoundParameters.ContainsKey('ResourceMeteringSaveIntervalMinute'))
    {
        # Need to convert the specified minutes into a TimeSpan object first
        $convertToTimeSpanParams = @{
            TimeInterval = $PSBoundParameters['ResourceMeteringSaveIntervalMinute']
            TimeIntervalType = 'Minutes'
        }
        $resourceMeteringSaveInterval = ConvertTo-TimeSpan @convertToTimeSpanParams

        # Remove the existing UInt32 explicit type and add the TimeSpan type parameter
        $null = $PSBoundParameters.Remove('ResourceMeteringSaveIntervalMinute')
        $PSBoundParameters['ResourceMeteringSaveInterval'] = $resourceMeteringSaveInterval
    }

    if ($PSBoundParameters.ContainsKey('VirtualMachineMigrationEnabled'))
    {
        $null = $PSBoundParameters.Remove('VirtualMachineMigrationEnabled')

        if ($VirtualMachineMigrationEnabled)
        {
            if ((Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain)
            {
                Write-Verbose -Message $localizedData.EnableLiveMigration
                Enable-VMMigration
            }
            else
            {
                New-InvalidOperationError -ErrorId InvalidState -ErrorMessage $localizedData.LiveMigrationDomainOnly
            }
        }
        else
        {
            Write-Verbose -Message $localizedData.DisableLiveMigration
            Disable-VMMigration
        }
    }

    $vmHostParams = $PSBoundParameters.GetEnumerator() | Where-Object -FilterScript {
        $_.Key -notin (
            [System.Management.Automation.PSCmdlet]::CommonParameters +
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
        )
    }

    if ($vmHostParams.Count -ne 0)
    {
        Write-Verbose -Message $localizedData.UpdatingVMHostProperties
        Set-VMHost @PSBoundParameters
        Write-Verbose -Message $localizedData.VMHostPropertiesUpdated
    }
} #end function

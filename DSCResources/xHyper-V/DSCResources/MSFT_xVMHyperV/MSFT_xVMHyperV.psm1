$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/DscResource.Common'
$script:hyperVDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/HyperVDsc.Common'

Import-Module -Name $script:dscResourceCommonModulePath
Import-Module -Name $script:hyperVDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VhdPath
    )

    Write-Verbose -Message ($script:localizedData.QueryingVM -f $Name)

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        throw ($script:localizedData.RoleMissingError -f 'Hyper-V')
    }

    $vmobj = Get-VM -Name $Name -ErrorAction SilentlyContinue

    # Check if 1 or 0 VM with name = $name exist
    if ($vmobj.count -gt 1)
    {
        throw ($script:localizedData.MoreThanOneVMExistsError -f $Name)
    }

    <#
        Retrieve the Vhd hierarchy to ensure we enumerate snapshots/differencing disks
        Fixes #28
    #>
    if ($null -ne $vmobj)
    {
        $vhdChain = @(Get-VhdHierarchy -VhdPath ($vmObj.HardDrives[0].Path))
    }

    $vmSecureBootState = $false
    if ($vmobj.Generation -eq 2)
    {
        # Retrieve secure boot status (can only be enabled on Generation 2 VMs) and convert to a boolean.
        $vmSecureBootState = ($vmobj | Get-VMFirmware).SecureBoot -eq 'On'
    }

    $guestServiceId = 'Microsoft:{0}\6C09BB55-D683-4DA0-8931-C9BF705F6480' -f $vmObj.Id

    $macAddress = @()
    $switchName = @()
    $ipAddress = @()

    foreach ($networkAdapter in $vmobj.NetworkAdapters)
    {
        $macAddress += $networkAdapter.MacAddress

        if (-Not ([System.String]::IsNullOrEmpty($networkAdapter.SwitchName)))
        {
            $switchName += $networkAdapter.SwitchName
        }

        if ($networkAdapter.IPAddresses.Count -ge 1)
        {
            $ipAddress += $networkAdapter.IPAddresses
        }
    }

    @{
        Name                        = $Name
        # Return the Vhd specified if it exists in the Vhd chain
        VhdPath                     = if ($vhdChain -contains $VhdPath)
        {
            $VhdPath
        }
        else
        {
            $null
        }
        SwitchName                  = $switchName
        State                       = $vmobj.State
        Path                        = $vmobj.Path
        Generation                  = $vmobj.Generation
        SecureBoot                  = $vmSecureBootState
        StartupMemory               = $vmobj.MemoryStartup
        MinimumMemory               = $vmobj.MemoryMinimum
        MaximumMemory               = $vmobj.MemoryMaximum
        MACAddress                  = $macAddress
        ProcessorCount              = $vmobj.ProcessorCount
        Ensure                      = if ($vmobj)
        {
            'Present'
        }
        else
        {
            'Absent'
        }
        ID                          = $vmobj.Id
        Status                      = $vmobj.Status
        CPUUsage                    = $vmobj.CPUUsage
        MemoryAssigned              = $vmobj.MemoryAssigned
        Uptime                      = $vmobj.Uptime
        CreationTime                = $vmobj.CreationTime
        HasDynamicMemory            = $vmobj.DynamicMemoryEnabled
        NetworkAdapters             = $ipAddress
        EnableGuestService          = ($vmobj | Get-VMIntegrationService | Where-Object -FilterScript { $_.Id -eq $guestServiceId }).Enabled
        AutomaticCheckpointsEnabled = $vmobj.AutomaticCheckpointsEnabled
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        # Name of the VM
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # VHD associated with the VM
        [Parameter(Mandatory = $true)]
        [System.String]
        $VhdPath,

        # Virtual switch associated with the VM
        [Parameter()]
        [System.String[]]
        $SwitchName,

        # State of the VM
        [Parameter()]
        [ValidateSet('Running', 'Paused', 'Off')]
        [System.String]
        $State,

        # Folder where the VM data will be stored
        [Parameter()]
        [System.String]
        $Path,

        # Virtual machine generation
        [Parameter()]
        [ValidateRange(1, 2)]
        [System.UInt32]
        $Generation = 1,

        # Startup RAM for the VM
        [Parameter()]
        [ValidateRange(32MB, 65536MB)]
        [System.UInt64]
        $StartupMemory,

        # Minimum RAM for the VM. This enables dynamic memory
        [Parameter()]
        [ValidateRange(32MB, 65536MB)]
        [System.UInt64]
        $MinimumMemory,

        # Maximum RAM for the VM. This enables dynamic memory
        [Parameter()]
        [ValidateRange(32MB, 1048576MB)]
        [System.UInt64]
        $MaximumMemory,

        # MAC address of the VM
        [Parameter()]
        [System.String[]]
        $MACAddress,

        # Processor count for the VM
        [Parameter()]
        [System.UInt32]
        $ProcessorCount,

        # Waits for VM to get valid IP address
        [Parameter()]
        [System.Boolean]
        $WaitForIP,

        # If specified, shutdowns and restarts the VM as needed for property changes
        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded,

        # Should the VM be created or deleted
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Notes,

        # Enable secure boot for Generation 2 VMs
        [Parameter()]
        [System.Boolean]
        $SecureBoot = $true,

        # Enable Guest Services
        [Parameter()]
        [System.Boolean]
        $EnableGuestService = $false,

        # Enable AutomaticCheckpoints
        [Parameter()]
        [System.Boolean]
        $AutomaticCheckpointsEnabled
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        throw ($script:localizedData.RoleMissingError -f 'Hyper-V')
    }

    # Check if AutomaticCheckpointsEnabled is set in configuration
    if ($PSBoundParameters.ContainsKey('AutomaticCheckpointsEnabled'))
    {
        <#
            Check if AutomaticCheckpoints are supported
            If AutomaticCheckpoints are supported, parameter exists on Set-VM
        #>
        if (-Not (Get-Command -Name Set-VM -Module Hyper-V).Parameters.ContainsKey('AutomaticCheckpointsEnabled'))
        {
            throw ($script:localizedData.AutomaticCheckpointsUnsupported)
        }
    }

    Write-Verbose -Message ($script:localizedData.CheckingVMExists -f $Name)
    $vmObj = Get-VM -Name $Name -ErrorAction SilentlyContinue

    # VM already exists
    if ($vmObj)
    {
        Write-Verbose -Message ($script:localizedData.VMExists -f $Name)

        # If VM shouldn't be there, stop it and remove it
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'Ensure', $Ensure, 'Present')
            Get-VM $Name | Stop-VM -Force -Passthru -WarningAction SilentlyContinue | Remove-VM -Force
            Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'Ensure', $Ensure)
        }

        <#
            If VM is present, check its state, startup memory, minimum memory, maximum memory,processor count, automatic checkpoint and mac address
            One cannot set the VM's vhdpath, path, generation and switchName after creation
        #>
        else
        {
            # If state has been specified and the VM is not in right state, set it to right state
            if ($State -and ($vmObj.State -ne $State))
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'State', $State, $vmObj.State)
                Set-VMState -Name $Name -State $State -WaitForIP $WaitForIP
                Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'State', $State)
            }

            $changeProperty = @{ }
            # If the VM does not have the right startup memory
            if ($PSBoundParameters.ContainsKey('StartupMemory') -and ($vmObj.MemoryStartup -ne $StartupMemory))
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'MemoryStartup', $StartupMemory, $vmObj.MemoryStartup)
                $changeProperty['MemoryStartup'] = $StartupMemory
            }
            elseif ($PSBoundParameters.ContainsKey('MinimumMemory') -and ($vmObj.MemoryStartup -lt $MinimumMemory))
            {
                Write-Verbose -Message ($script:localizedData.AdjustingLessThanMemoryWarning -f 'StartupMemory', $vmObj.MemoryStartup, 'MinimumMemory', $MinimumMemory)
                $changeProperty['MemoryStartup'] = $MinimumMemory
            }
            elseif ($PSBoundParameters.ContainsKey('MaximumMemory') -and ($vmObj.MemoryStartup -gt $MaximumMemory))
            {
                Write-Verbose -Message ($script:localizedData.AdjustingGreaterThanMemoryWarning -f 'StartupMemory', $vmObj.MemoryStartup, 'MaximumMemory', $MaximumMemory)
                $changeProperty['MemoryStartup'] = $MaximumMemory
            }

            # If the VM does not have the right minimum or maximum memory, stop the VM, set the right memory, start the VM
            if ($PSBoundParameters.ContainsKey('MinimumMemory') -or $PSBoundParameters.ContainsKey('MaximumMemory'))
            {
                $changeProperty['DynamicMemory'] = $true
                $changeProperty['StaticMemory'] = $false

                if ($PSBoundParameters.ContainsKey('MinimumMemory') -and ($vmObj.Memoryminimum -ne $MinimumMemory))
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'MinimumMemory', $MinimumMemory, $vmObj.MemoryMinimum)
                    $changeProperty['MemoryMinimum'] = $MinimumMemory
                }
                if ($PSBoundParameters.ContainsKey('MaximumMemory') -and ($vmObj.Memorymaximum -ne $MaximumMemory))
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'MaximumMemory', $MaximumMemory, $vmObj.MemoryMaximum)
                    $changeProperty['MemoryMaximum'] = $MaximumMemory
                }
            }

            # If the VM does not have the right processor count, stop the VM, set the right memory, start the VM
            if ($PSBoundParameters.ContainsKey('ProcessorCount') -and ($vmObj.ProcessorCount -ne $ProcessorCount))
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'ProcessorCount', $ProcessorCount, $vmObj.ProcessorCount)
                $changeProperty['ProcessorCount'] = $ProcessorCount
            }

            # Stop the VM, set the right properties, start the VM only if there are properties to change
            if ($changeProperty.Count -gt 0)
            {
                Set-VMProperty -Name $Name -VMCommand 'Set-VM' -ChangeProperty $changeProperty -WaitForIP $WaitForIP -RestartIfNeeded $RestartIfNeeded
                Write-Verbose -Message ($script:localizedData.VMPropertiesUpdated -f $Name)
            }

            <#
                Special cases to disable dynamic memory:
                - If startup, minimum and maximum memory are specified with equal values or
                - If only startup memory is specified, but neither minimum nor maximum
            #>
            if ( ($PSBoundParameters.ContainsKey('StartupMemory') -and
                    ($StartupMemory -eq $MinimumMemory) -and
                    ($StartupMemory -eq $MaximumMemory)
                ) -or
                ( $PSBoundParameters.ContainsKey('StartupMemory') -and
                    (-not $PSBoundParameters.ContainsKey('MinimumMemory')) -and
                    (-not $PSBoundParameters.ContainsKey('MaximumMemory'))
                )
            )
            {
                # Refresh VM properties
                $vmObj = Get-VM -Name $Name -ErrorAction SilentlyContinue
                if ($vmObj.DynamicMemoryEnabled)
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'DynamicMemoryEnabled', $false, $vmObj.DynamicMemoryEnabled)
                    $setVMPropertyParams = @{
                        VMName          = $Name
                        VMCommand       = 'Set-VM'
                        ChangeProperty  = @{
                            StaticMemory  = $true
                            DynamicMemory = $false
                        }
                        WaitForIP       = $WaitForIP
                        RestartIfNeeded = $RestartIfNeeded
                    }
                    Set-VMProperty @setVMPropertyParams
                    Write-Verbose -Message ($script:localizedData.VMPropertiesUpdated -f $Name)
                }
            }

            # Set VM network switches. This can be done while the VM is running.
            for ($i = 0; $i -lt $SwitchName.Count; $i++)
            {
                $switch = $SwitchName[$i]
                $nic = $vmObj.NetworkAdapters[$i]
                if ($nic)
                {
                    # We cannot change the MAC address whilst the VM is running.. This is changed later
                    if ($nic.SwitchName -ne $switch)
                    {
                        Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'NIC', $switch, $nic.SwitchName)
                        $nic | Connect-VMNetworkAdapter -SwitchName $switch
                        Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                }
                else
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'NIC', $switch, '<missing>')
                    if ($MACAddress -and (-not [System.String]::IsNullOrEmpty($MACAddress[$i])))
                    {
                        Add-VMNetworkAdapter -VMName $Name -SwitchName $switch -StaticMacAddress $MACAddress[$i]
                        Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                    else
                    {
                        Add-VMNetworkAdapter -VMName $Name -SwitchName $switch
                        Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                    # Refresh the NICs after we've added one
                    $vmObj = Get-VM -Name $Name -ErrorAction SilentlyContinue
                }
            }

            # If the VM does not have the right MACAddress, stop the VM, set the right MACAddress, start the VM
            for ($i = 0; $i -lt $MACAddress.Count; $i++)
            {
                $address = $MACAddress[$i]
                $nic = $vmObj.NetworkAdapters[$i]
                if ($nic.MacAddress -ne $address)
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'MACAddress', $address, $nic.MacAddress)
                    Set-VMMACAddress -Name $Name -NICIndex $i -MACAddress $address -WaitForIP $WaitForIP -RestartIfNeeded $RestartIfNeeded
                }
            }

            if ($Generation -eq 2)
            {
                # Retrive the current secure boot state
                $vmSecureBoot = Test-VMSecureBoot -Name $Name
                if ($SecureBoot -ne $vmSecureBoot)
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'SecureBoot', $SecureBoot, $vmSecureBoot)

                    if (-not $SecureBoot)
                    {
                        $enableSecureBoot = 'On'
                    }
                    else
                    {
                        $enableSecureBoot = 'Off'
                    }

                    # Cannot change the secure boot state whilst the VM is powered on.
                    $setVMPropertyParams = @{
                        VMName          = $Name
                        VMCommand       = 'Set-VMFirmware'
                        ChangeProperty  = @{
                            EnableSecureBoot = $enableSecureBoot
                        }
                        RestartIfNeeded = $RestartIfNeeded
                    }
                    Set-VMProperty @setVMPropertyParams
                    Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'SecureBoot', $SecureBoot)
                }
            }

            if ($Notes -ne $null)
            {
                # If the VM notes do not match the desire notes, update them.  This can be done while the VM is running.
                if ($vmObj.Notes -ne $Notes)
                {
                    Set-Vm -Name $Name -Notes $Notes
                }
            }

            # If the VM doesn't have Guest Service Interface correctly configured, update it.
            $guestServiceId = 'Microsoft:{0}\6C09BB55-D683-4DA0-8931-C9BF705F6480' -f $vmObj.Id

            $guestService = $vmObj | Get-VMIntegrationService | Where-Object -FilterScript { $_.Id -eq $guestServiceId }
            if ($guestService.Enabled -eq $false -and $EnableGuestService)
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'EnableGuestService', $EnableGuestService, $guestService.Enabled)
                $guestService | Enable-VMIntegrationService
                Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'EnableGuestService', $EnableGuestService)
            }
            elseif ($guestService.Enabled -and -not $EnableGuestService)
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'EnableGuestService', $EnableGuestService, $guestService.Enabled)
                $guestService | Disable-VMIntegrationService
                Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'EnableGuestService', $EnableGuestService)
            }

            # If AutomaticCheckpointsEnabled is set in configuration
            if ($PSBoundParameters.ContainsKey('AutomaticCheckpointsEnabled'))
            {
                if ($vmObj.AutomaticCheckpointsEnabled -ne $AutomaticCheckpointsEnabled)
                {
                    Set-VM -Name $Name -AutomaticCheckpointsEnabled $AutomaticCheckpointsEnabled
                }
            }
        }
    }

    # VM is not present, create one
    else
    {
        Write-Verbose -Message ($script:localizedData.VMDoesNotExist -f $Name)
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.CreatingVM -f $Name)

            $parameters = @{ }
            $parameters['Name'] = $Name
            $parameters['VHDPath'] = $VhdPath
            $parameters['Generation'] = $Generation

            # Optional parameters
            if ($SwitchName)
            {
                $parameters['SwitchName'] = $SwitchName[0]
            }
            if ($Path)
            {
                $parameters['Path'] = $Path
            }
            $defaultStartupMemory = 512MB
            if ($PSBoundParameters.ContainsKey('StartupMemory'))
            {
                $parameters['MemoryStartupBytes'] = $StartupMemory
            }
            elseif ($PSBoundParameters.ContainsKey('MinimumMemory') -and ($defaultStartupMemory -lt $MinimumMemory))
            {
                $parameters['MemoryStartupBytes'] = $MinimumMemory
            }
            elseif ($PSBoundParameters.ContainsKey('MaximumMemory') -and ($defaultStartupMemory -gt $MaximumMemory))
            {
                $parameters['MemoryStartupBytes'] = $MaximumMemory
            }
            $null = New-VM @parameters

            $parameters = @{ }
            $parameters['Name'] = $Name
            $parameters['StaticMemory'] = $true
            $parameters['DynamicMemory'] = $false
            if ($PSBoundParameters.ContainsKey('MinimumMemory') -or $PSBoundParameters.ContainsKey('MaximumMemory'))
            {
                $parameters['DynamicMemory'] = $true
                $parameters['StaticMemory'] = $false
                if ($PSBoundParameters.ContainsKey('MinimumMemory'))
                {
                    $parameters['MemoryMinimumBytes'] = $MinimumMemory
                }
                if ($PSBoundParameters.ContainsKey('MaximumMemory'))
                {
                    $parameters['MemoryMaximumBytes'] = $MaximumMemory
                }
            }

            if ($Notes)
            {
                $parameters['Notes'] = $Notes
            }

            if ($PSBoundParameters.ContainsKey('ProcessorCount'))
            {
                $parameters['ProcessorCount'] = $ProcessorCount
            }

            # If AutomaticCheckpointsEnabled is set in configuration
            if ($PSBoundParameters.ContainsKey('AutomaticCheckpointsEnabled'))
            {
                $parameters['AutomaticCheckpointsEnabled'] = $AutomaticCheckpointsEnabled
            }

            $null = Set-VM @parameters

            # Special case: Disable dynamic memory if startup, minimum and maximum memory are equal
            if ($PSBoundParameters.ContainsKey('StartupMemory') -and
                ($StartupMemory -eq $MinimumMemory) -and
                ($StartupMemory -eq $MaximumMemory))
            {
                Set-VMMemory -VMName $Name -DynamicMemoryEnabled $false
            }

            # There's always a NIC added with New-VM
            if ($MACAddress)
            {
                Set-VMNetworkAdapter -VMName $Name -StaticMacAddress $MACAddress[0]
            }

            # Add additional NICs
            for ($i = 1; $i -lt $SwitchName.Count; $i++)
            {
                $addVMNetworkAdapterParams = @{
                    VMName     = $Name
                    SwitchName = $SwitchName[$i]
                }
                if ($MACAddress -and (-not [System.String]::IsNullOrEmpty($MACAddress[$i])))
                {
                    $addVMNetworkAdapterParams['StaticMacAddress'] = $MACAddress[$i]
                }
                Add-VMNetworkAdapter @addVMNetworkAdapterParams
                Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'NIC', $SwitchName[$i])
            }

            if ($Generation -eq 2)
            {
                <#
                    Secure boot is only applicable to Generation 2 VMs and it defaults to on.
                    Therefore, we only need to explicitly set it to off if specified.
                #>
                if ($SecureBoot -eq $false)
                {
                    Set-VMFirmware -VMName $Name -EnableSecureBoot Off
                }
            }

            if ($EnableGuestService)
            {
                $guestServiceId = 'Microsoft:{0}\6C09BB55-D683-4DA0-8931-C9BF705F6480' -f (Get-VM -Name $Name).Id
                Get-VMIntegrationService -VMName $Name | Where-Object -FilterScript { $_.Id -eq $guestServiceId } | Enable-VMIntegrationService
            }

            Write-Verbose -Message ($script:localizedData.VMCreated -f $Name)

            if ($State)
            {
                Set-VMState -Name $Name -State $State -WaitForIP $WaitForIP
                Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'State', $State)
            }

        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # Name of the VM
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # VHD associated with the VM
        [Parameter(Mandatory = $true)]
        [System.String]
        $VhdPath,

        # Virtual switch associated with the VM
        [Parameter()]
        [System.String[]]
        $SwitchName,

        # State of the VM
        [Parameter()]
        [ValidateSet('Running', 'Paused', 'Off')]
        [System.String]
        $State,

        # Folder where the VM data will be stored
        [Parameter()]
        [System.String]
        $Path,

        # Virtual machine generation
        [Parameter()]
        [ValidateRange(1, 2)]
        [System.UInt32]
        $Generation = 1,

        # Startup RAM for the VM
        [Parameter()]
        [ValidateRange(32MB, 65536MB)]
        [System.UInt64]
        $StartupMemory,

        # Minimum RAM for the VM. This enables dynamic memory
        [Parameter()]
        [ValidateRange(32MB, 65536MB)]
        [System.UInt64]
        $MinimumMemory,

        # Maximum RAM for the VM. This enables dynamic memory
        [Parameter()]
        [ValidateRange(32MB, 1048576MB)]
        [System.UInt64]
        $MaximumMemory,

        # MAC address of the VM
        [Parameter()]
        [System.String[]]
        $MACAddress,

        # Processor count for the VM
        [Parameter()]
        [System.UInt32]
        $ProcessorCount,

        # Waits for VM to get valid IP address
        [Parameter()]
        [System.Boolean]
        $WaitForIP,

        # If specified, shutdowns and restarts the VM as needed for property changes
        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded,

        # Should the VM be created or deleted
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Notes,

        # Enable secure boot for Generation 2 VMs
        [Parameter()]
        [System.Boolean]
        $SecureBoot = $true,

        [Parameter()]
        [System.Boolean]
        $EnableGuestService = $false,

        # Enable AutomaticCheckpoints
        [Parameter()]
        [System.Boolean]
        $AutomaticCheckpointsEnabled
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        throw ($script:localizedData.RoleMissingError -f 'Hyper-V')
    }

    # Check if 1 or 0 VM with name = $name exist
    if ((Get-VM -Name $Name -ErrorAction SilentlyContinue).count -gt 1)
    {
        throw ($script:localizedData.MoreThanOneVMExistsError -f $Name)
    }

    # Check if AutomaticCheckpointsEnabled is set in configuration
    if ($PSBoundParameters.ContainsKey('AutomaticCheckpointsEnabled'))
    {
        <#
            Check if AutomaticCheckpoints are supported
            If AutomaticCheckpoints are supported, parameter exists on Set-VM
        #>
        if (-Not (Get-Command -Name Set-VM -Module Hyper-V).Parameters.ContainsKey('AutomaticCheckpointsEnabled'))
        {
            throw ($script:localizedData.AutomaticCheckpointsUnsupported)
        }
    }

    try
    {
        $vmObj = Get-VM -Name $Name -ErrorAction Stop
        if ($Ensure -eq 'Present')
        {
            # Check if $VhdPath exist
            if (!(Test-Path $VhdPath))
            {
                throw ($script:localizedData.VhdPathDoesNotExistError -f $VhdPath)
            }

            # Check if Minimum memory is less than StartUpmemory
            if ($PSBoundParameters.ContainsKey('StartupMemory') -and
                $PSBoundParameters.ContainsKey('MinimumMemory') -and
                ($MinimumMemory -gt $StartupMemory))
            {
                throw ($script:localizedData.MinMemGreaterThanStartupMemError -f $MinimumMemory, $StartupMemory)
            }

            # Check if Minimum memory is greater than Maximummemory
            if ($PSBoundParameters.ContainsKey('MaximumMemory') -and
                $PSBoundParameters.ContainsKey('MinimumMemory') -and
                ($MinimumMemory -gt $MaximumMemory))
            {
                throw ($script:localizedData.MinMemGreaterThanMaxMemError -f $MinimumMemory, $MaximumMemory)
            }

            # Check if Startup memory is greater than Maximummemory
            if ($PSBoundParameters.ContainsKey('MaximumMemory') -and
                $PSBoundParameters.ContainsKey('StartupMemory') -and
                ($StartupMemory -gt $MaximumMemory))
            {
                throw ($script:localizedData.StartUpMemGreaterThanMaxMemError -f $StartupMemory, $MaximumMemory)
            }

            <#
                VM Generation has no direct relation to the virtual hard disk format and cannot be changed
                after the virtual machine has been created. Generation 2 VMs do not support .VHD files.
            #>
            if (($Generation -eq 2) -and ($VhdPath.Split('.')[-1] -eq 'vhd'))
            {
                throw ($script:localizedData.VhdUnsupportedOnGen2VMError)
            }

            # Check if $Path exist
            if ($Path -and !(Test-Path -Path $Path))
            {
                throw ($script:localizedData.PathDoesNotExistError -f $Path)
            }

            $vhdChain = @(Get-VhdHierarchy -VhdPath ($vmObj.HardDrives[0].Path))
            if ($vhdChain -notcontains $VhdPath)
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'VhdPath', $VhdPath, ($vhdChain -join ','))
                return $false
            }

            if ($state -and ($vmObj.State -ne $State))
            {
                return $false
            }

            if ($PSBoundParameters.ContainsKey('StartupMemory') -and
                ($vmObj.MemoryStartup -ne $StartupMemory))
            {
                return $false
            }

            if ($PSBoundParameters.ContainsKey('MaximumMemory') -and
                ($vmObj.MemoryMaximum -ne $MaximumMemory))
            {
                return $false
            }

            if ($PSBoundParameters.ContainsKey('MinimumMemory') -and
                ($vmObj.MemoryMinimum -ne $MinimumMemory))
            {
                return $false
            }

            # If startup memory but neither minimum nor maximum memory specified, dynamic memory should be disabled
            if ($PSBoundParameters.ContainsKey('StartupMemory') -and
                ( -not $PSBoundParameters.ContainsKey('MinimumMemory')) -and
                ( -not $PSBoundParameters.ContainsKey('MaximumMemory')) -and
                $vmobj.DynamicMemoryEnabled)
            {
                return $false
            }

            # If startup, minimum and maximum memory are specified with the same values, dynamic memory should be disabled
            if ($PSBoundParameters.ContainsKey('StartupMemory') -and
                $PSBoundParameters.ContainsKey('MinimumMemory') -and
                $PSBoundParameters.ContainsKey('MaximumMemory') -and
                ($StartupMemory -eq $MinimumMemory) -and
                ($StartupMemory -eq $MaximumMemory) -and
                $vmobj.DynamicMemoryEnabled)
            {
                return $false
            }

            if ($vmObj.HardDrives.Path -notcontains $VhdPath)
            {
                return $false
            }

            for ($i = 0; $i -lt $SwitchName.Count; $i++)
            {
                if ($vmObj.NetworkAdapters[$i].SwitchName -ne $SwitchName[$i])
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'SwitchName', $SwitchName[$i], $vmObj.NetworkAdapters[$i].SwitchName)
                    return $false
                }
            }

            for ($i = 0; $i -lt $MACAddress.Count; $i++)
            {
                if ($vmObj.NetworkAdapters[$i].MACAddress -ne $MACAddress[$i])
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'MACAddress', $MACAddress[$i], $vmObj.NetworkAdapters[$i].MACAddress)
                    return $false
                }
            }

            # $Generation always exists, only check if parameter has been explicitly specified
            if ($PSBoundParameters.ContainsKey('Generation') -and ($Generation -ne $vmObj.Generation))
            {
                return $false
            }

            if ($PSBoundParameters.ContainsKey('ProcessorCount') -and ($vmObj.ProcessorCount -ne $ProcessorCount))
            {
                return $false
            }

            if ($vmObj.Generation -eq 2)
            {
                $vmSecureBoot = Test-VMSecureBoot -Name $Name
                if ($SecureBoot -ne $vmSecureBoot)
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'SecureBoot', $SecureBoot, $vmSecureBoot)
                    return $false
                }
            }

            $guestServiceId = 'Microsoft:{0}\6C09BB55-D683-4DA0-8931-C9BF705F6480' -f $vmObj.Id
            $guestService = $vmObj | Get-VMIntegrationService | Where-Object -FilterScript { $_.Id -eq $guestServiceId }
            if ($guestService.Enabled -ne $EnableGuestService)
            {
                Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'EnableGuestService', $EnableGuestService, $guestService.Enabled)
                return $false
            }

            # If AutomaticCheckpointsEnabled is set in configuration
            if ($PSBoundParameters.ContainsKey('AutomaticCheckpointsEnabled'))
            {
                if ($vmObj.AutomaticCheckpointsEnabled -ne $AutomaticCheckpointsEnabled)
                {
                    Write-Verbose -Message ($script:localizedData.VMPropertyShouldBe -f 'AutomaticCheckpointsEnabled', $AutomaticCheckpointsEnabled, $vmObj.AutomaticCheckpointsEnabled)
                    return $false
                }
            }

            return $true
        }
        else
        {
            return $false
        }
    }
    catch [System.Management.Automation.ActionPreferenceStopException]
    {
        ($Ensure -eq 'Absent')
    }
}

#region Helper function

# Returns VM VHDs, including snapshots and differencing disks
function Get-VhdHierarchy
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VhdPath
    )

    $vmVhdPath = Get-VHD -Path $VhdPath
    Write-Output -InputObject $vmVhdPath.Path
    while (-not [System.String]::IsNullOrEmpty($vmVhdPath.ParentPath))
    {
        $vmVhdPath.ParentPath
        $vmVhdPath = (Get-VHD -Path $vmVhdPath.ParentPath)
    }
}

<#
    The 'Set-VMProperty' method cannot be used as it cannot deal with piped
    command in it's current implementation
#>
function Set-VMMACAddress
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MACAddress,

        [Parameter(Mandatory = $true)]
        [Int]
        $NICIndex,

        [Parameter()]
        [System.Boolean]
        $WaitForIP,

        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded
    )
    $vmObj = Get-VM -Name $Name
    $originalState = $vmObj.state
    if ($originalState -ne 'Off' -and $RestartIfNeeded)
    {
        Set-VMState -Name $Name -State Off
        $vmObj.NetworkAdapters[$NICIndex] | Set-VMNetworkAdapter -StaticMacAddress $MACAddress

        # Can not move a off VM to paused, but only to running state
        if ($originalState -eq 'Running')
        {
            Set-VMState -Name $Name -State Running -WaitForIP $WaitForIP
        }

        # Cannot make a paused VM to go back to Paused state after turning Off
        if ($originalState -eq 'Paused')
        {
            Write-Warning -Message ($script:localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif ($originalState -eq 'Off')
    {
        $vmObj.NetworkAdapters[$NICIndex] | Set-VMNetworkAdapter -StaticMacAddress $MACAddress
        Write-Verbose -Message ($script:localizedData.VMPropertySet -f 'MACAddress', $MACAddress)
    }
    else
    {
        Write-Error -Message ($script:localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmObj.State)
    }
}

function Test-VMSecureBoot
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    $vm = Get-VM -Name $Name
    return (Get-VMFirmware -VM $vm).SecureBoot -eq 'On'
}

#endregion

Export-ModuleMember -Function *-TargetResource

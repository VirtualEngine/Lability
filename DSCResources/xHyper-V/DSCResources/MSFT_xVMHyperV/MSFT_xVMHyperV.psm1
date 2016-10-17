# Fallback message strings in en-US
DATA localizedData
{
    # culture = "en-US"
    ConvertFrom-StringData @'
        RoleMissingError = Please ensure that '{0}' role is installed with its PowerShell module.
        MoreThanOneVMExistsError = More than one VM with the name '{0}' exists.
        PathDoesNotExistError = Path '{0}' does not exist.
        VhdPathDoesNotExistError = Vhd '{0}' does not exist.
        MinMemGreaterThanStartupMemError = MinimumMemory '{0}' should not be greater than StartupMemory '{1}'
        MinMemGreaterThanMaxMemError = MinimumMemory '{0}' should not be greater than MaximumMemory '{1}'
        StartUpMemGreaterThanMaxMemError = StartupMemory '{0}' should not be greater than MaximumMemory '{1}'.
        VhdUnsupportedOnGen2VMError = Generation 2 virtual machines do not support the .VHD virtual disk extension.
        CannotUpdatePropertiesOnlineError = Can not change properties for VM '{0}' in '{1}' state unless 'RestartIfNeeded' is set to true.
        
        AdjustingGreaterThanMemoryWarning = VM {0} '{1}' is greater than {2} '{3}'. Adjusting {0} to be '{3}'.
        AdjustingLessThanMemoryWarning = VM {0} '{1}' is less than {2} '{3}'. Adjusting {0} to be '{3}'.
        VMStateWillBeOffWarning = VM '{0}' state will be 'OFF' and not 'Paused'.
        
        CheckingVMExists = Checking if VM '{0}' exists ...
        VMExists = VM '{0}' exists.
        VMDoesNotExist = VM '{0}' does not exist.
        CreatingVM = Creating VM '{0}' ...
        VMCreated = VM '{0}' created.
        VMPropertyShouldBe = VM property '{0}' should be '{1}', actual '{2}'.
        VMPropertySet = VM property '{0}' is '{1}'.
        VMPropertiesUpdated = VM '{0}' properties have been updated.
        WaitingForVMIPAddress = Waiting for IP Address for VM '{0}' ...
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $VhdPath
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw ($localizedData.RoleMissingError -f 'Hyper-V')
    }

    $vmobj = Get-VM -Name $Name -ErrorAction SilentlyContinue
    
    # Check if 1 or 0 VM with name = $name exist
    if($vmobj.count -gt 1)
    {
       Throw ($localizedData.MoreThanOneVMExistsError -f $Name) 
    }
    
    ## Retrieve the Vhd hierarchy to ensure we enumerate snapshots/differencing disks
    ## Fixes #28
    $vhdChain = @(Get-VhdHierarchy -VhdPath ($vmObj.HardDrives[0].Path))
    
    $vmSecureBootState = $false;
    if ($vmobj.Generation -eq 2) {
       # Retrieve secure boot status (can only be enabled on Generation 2 VMs) and convert to a boolean.
       $vmSecureBootState = ($vmobj | Get-VMFirmware).SecureBoot -eq 'On'
    } 
    
    @{
        Name             = $Name
        ## Return the Vhd specified if it exists in the Vhd chain
        VhdPath          = if ($vhdChain -contains $VhdPath) { $VhdPath };
        SwitchName       = $vmObj.NetworkAdapters.SwitchName
        State            = $vmobj.State
        Path             = $vmobj.Path
        Generation       = $vmobj.Generation
        SecureBoot       = $vmSecureBootState
        StartupMemory    = $vmobj.MemoryStartup
        MinimumMemory    = $vmobj.MemoryMinimum
        MaximumMemory    = $vmobj.MemoryMaximum
        MACAddress       = $vmObj.NetWorkAdapters.MacAddress
        ProcessorCount   = $vmobj.ProcessorCount
        Ensure           = if($vmobj){"Present"}else{"Absent"}
        ID               = $vmobj.Id
        Status           = $vmobj.Status
        CPUUsage         = $vmobj.CPUUsage
        MemoryAssigned   = $vmobj.MemoryAssigned
        Uptime           = $vmobj.Uptime
        CreationTime     = $vmobj.CreationTime
        HasDynamicMemory = $vmobj.DynamicMemoryEnabled
        NetworkAdapters  = $vmobj.NetworkAdapters.IPAddresses
        EnableGuestService = ($vmobj | Get-VMIntegrationService -Name 'Guest Service Interface').Enabled
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        # Name of the VM
        [parameter(Mandatory)]
        [String]$Name,
        
        # VHD associated with the VM
        [parameter(Mandatory)]
        [String]$VhdPath,
        
        # Virtual switch associated with the VM
        [String[]]$SwitchName,

        # State of the VM
        [AllowNull()]
        [ValidateSet("Running","Paused","Off")]
        [String]$State,

        # Folder where the VM data will be stored
        [String]$Path,

        # Virtual machine generation
        [ValidateRange(1,2)]
        [UInt32]$Generation = 1,

        # Startup RAM for the VM
        [ValidateRange(32MB,17342MB)]
        [UInt64]$StartupMemory,

        # Minimum RAM for the VM. This enables dynamic memory
        [ValidateRange(32MB,17342MB)]
        [UInt64]$MinimumMemory,

        # Maximum RAM for the VM. This enables dynamic memory
        [ValidateRange(32MB,1048576MB)]
        [UInt64]$MaximumMemory,

        # MAC address of the VM
        [String[]]$MACAddress,

        # Processor count for the VM
        [UInt32]$ProcessorCount,

        # Waits for VM to get valid IP address
        [Boolean]$WaitForIP,

        # If specified, shutdowns and restarts the VM as needed for property changes
        [Boolean]$RestartIfNeeded,

        # Should the VM be created or deleted
        [ValidateSet("Present","Absent")]
        [String]$Ensure = "Present",
        [System.String]
        $Notes,

        # Enable secure boot for Generation 2 VMs
        [Boolean]$SecureBoot = $true,

        # Enable Guest Services
        [Boolean]$EnableGuestService = $false
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw ($localizedData.RoleMissingError -f 'Hyper-V')
    }

    Write-Verbose -Message ($localizedData.CheckingVMExists -f $Name)
    $vmObj = Get-VM -Name $Name -ErrorAction SilentlyContinue

    # VM already exists
    if($vmObj)
    {
        Write-Verbose -Message ($localizedData.VMExists -f $Name)

        # If VM shouldn't be there, stop it and remove it
        if($Ensure -eq "Absent")
        {
            Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'Ensure', $Ensure, 'Present')
            Get-VM $Name | Stop-VM -Force -Passthru -WarningAction SilentlyContinue | Remove-VM -Force
            Write-Verbose -Message ($localizedData.VMPropertySet -f 'Ensure', $Ensure)
        }

        # If VM is present, check its state, startup memory, minimum memory, maximum memory,processor countand mac address
        # One cannot set the VM's vhdpath, path, generation and switchName after creation 
        else
        {
            # If state has been specified and the VM is not in right state, set it to right state
            if($State -and ($vmObj.State -ne $State))
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'State', $State, $vmObj.State)
                Set-VMState -Name $Name -State $State -WaitForIP $WaitForIP
                Write-Verbose -Message ($localizedData.VMPropertySet -f 'State', $State)
            }

            $changeProperty = @{}
            # If the VM does not have the right startup memory
            if($StartupMemory -and ($vmObj.MemoryStartup -ne $StartupMemory))
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'MemoryStartup', $StartupMemory, $vmObj.MemoryStartup)
                $changeProperty["MemoryStartup"]=$StartupMemory
            }
            elseif($MinimumMemory -and ($vmObj.MemoryStartup -lt $MinimumMemory))
            {
                Write-Verbose -Message ($localizedData.AdjustingLessThanMemoryWarning -f 'StartupMemory', $vmObj.MemoryStartup, 'MinimumMemory', $MinimumMemory)
                $changeProperty["MemoryStartup"]=$MinimumMemory
            }
            elseif($MaximumMemory -and ($vmObj.MemoryStartup -gt $MaximumMemory))
            {
                Write-Verbose -Message ($localizedData.AdjustingGreaterThanMemoryWarning -f 'StartupMemory', $vmObj.MemoryStartup, 'MaximumMemory', $MaximumMemory)
                $changeProperty["MemoryStartup"]=$MaximumMemory
            }
            
            # If the VM does not have the right minimum or maximum memory, stop the VM, set the right memory, start the VM
            if($MinimumMemory -or $MaximumMemory)
            {
                $changeProperty["DynamicMemory"]=$true

                if($MinimumMemory -and ($vmObj.Memoryminimum -ne $MinimumMemory))
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'MinimumMemory', $MinimumMemory, $vmObj.MemoryMinimum)
                    $changeProperty["MemoryMinimum"]=$MinimumMemory
                }
                if($MaximumMemory -and ($vmObj.Memorymaximum -ne $MaximumMemory))
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'MaximumMemory', $MaximumMemory, $vmObj.MemoryMaximum)
                    $changeProperty["MemoryMaximum"]=$MaximumMemory
                }
            }

            # If the VM does not have the right processor count, stop the VM, set the right memory, start the VM
            if($ProcessorCount -and ($vmObj.ProcessorCount -ne $ProcessorCount))
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'ProcessorCount', $ProcessorCount, $vmObj.ProcessorCount)
                $changeProperty["ProcessorCount"]=$ProcessorCount
            }

            # Stop the VM, set the right properties, start the VM only if there are properties to change
            if ($changeProperty.Count -gt 0) {
                Change-VMProperty -Name $Name -VMCommand "Set-VM" -ChangeProperty $changeProperty -WaitForIP $WaitForIP -RestartIfNeeded $RestartIfNeeded
                Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)
            }

            ## Set VM network switches. This can be done while the VM is running.
            for ($i = 0; $i -lt $SwitchName.Count; $i++)
            {
                ### Change-VMProperty -Name $Name -VMCommand "Set-VMNetworkAdapter" -ChangeProperty @{StaticMacAddress=$MACAddress} -WaitForIP $WaitForIP -RestartIfNeeded $RestartIfNeeded
                $switch = $SwitchName[$i]
                $nic = $vmObj.NetworkAdapters[$i]
                if ($nic) {
                    ## We cannot change the MAC address whilst the VM is running.. This is changed later
                    if ($nic.SwitchName -ne $switch) {
                        Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'NIC', $switch, $nic.SwitchName)
                        $nic | Connect-VMNetworkAdapter -SwitchName $switch
                        Write-Verbose -Message ($localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                }
                else {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'NIC', $switch, '<missing>')
                    if ($MACAddress -and (-not [System.String]::IsNullOrEmpty($MACAddress[$i])))
                    {
                        Add-VMNetworkAdapter -VMName $Name -SwitchName $switch -StaticMacAddress $MACAddress[$i]
                        Write-Verbose -Message ($localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                    else
                    {
                        Add-VMNetworkAdapter -VMName $Name -SwitchName $switch
                        Write-Verbose -Message ($localizedData.VMPropertySet -f 'NIC', $switch)
                    }
                    ## Refresh the NICs after we've added one
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
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'MACAddress', $address, $nic.MacAddress)
                    Change-VMMACAddress -Name $Name -NICIndex $i -MACAddress $address -WaitForIP $WaitForIP -RestartIfNeeded $RestartIfNeeded
                }
            }

            if ($Generation -eq 2)
            {
                ## Retrive the current secure boot state
                $vmSecureBoot = Test-VMSecureBoot -Name $Name
                if ($SecureBoot -ne $vmSecureBoot)
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'SecureBoot', $SecureBoot, $vmSecureBoot)
                    ## Cannot change the secure boot state whilst the VM is powered on.
                    Change-VMSecureBoot -Name $Name -SecureBoot $SecureBoot -RestartIfNeeded $RestartIfNeeded
                    Write-Verbose -Message ($localizedData.VMPropertySet -f 'SecureBoot', $SecureBoot)
                }
            }

            if($Notes -ne $null)
            {
                # If the VM notes do not match the desire notes, update them.  This can be done while the VM is running.
                if($vmObj.Notes -ne $Notes)
                {
                    Set-Vm -Name $Name -Notes $Notes
                }
            }

            #If the VM doesn't have Guest Service Interface correctly configured, update it.
            $GuestServiceStatus = $vmObj | Get-VMIntegrationService -Name 'Guest Service Interface'
            if ($GuestServiceStatus.Enabled -eq $false -and $EnableGuestService)
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'EnableGuestService', $EnableGuestService, $GuestServiceStatus.Enabled)
                $vmObj | Enable-VMIntegrationService -Name 'Guest Service Interface'
                Write-Verbose -Message ($localizedData.VMPropertySet -f 'EnableGuestService', $EnableGuestService)
            }
            elseif ($GuestServiceStatus.Enabled -and -not $EnableGuestService)
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'EnableGuestService', $EnableGuestService, $GuestServiceStatus.Enabled)
                $vmObj | Disable-VMIntegrationService -Name 'Guest Service Interface'
                Write-Verbose -Message ($localizedData.VMPropertySet -f 'EnableGuestService', $EnableGuestService)
            }
        }
    }

    # VM is not present, create one
    else
    {
        Write-Verbose -Message ($localizedData.VMDoesNotExist -f $Name)
        if($Ensure -eq "Present")
        {
            Write-Verbose -Message ($localizedData.CreatingVM -f $Name)
            
            $parameters = @{}
            $parameters["Name"] = $Name
            $parameters["VHDPath"] = $VhdPath
            $parameters["Generation"] = $Generation

            # Optional parameters
            if($SwitchName)
            {
                $parameters["SwitchName"]=$SwitchName[0]
            }
            if($Path){$parameters["Path"]=$Path}
            $defaultStartupMemory = 512MB
            if($StartupMemory){$parameters["MemoryStartupBytes"]=$StartupMemory}
            elseif($MinimumMemory -and $defaultStartupMemory -lt $MinimumMemory){$parameters["MemoryStartupBytes"]=$MinimumMemory}
            elseif($MaximumMemory -and $defaultStartupMemory -gt $MaximumMemory){$parameters["MemoryStartupBytes"]=$MaximumMemory}
            $null = New-VM @parameters

            $parameters = @{}
            $parameters["Name"] = $Name
            if($MinimumMemory -or $MaximumMemory)
            {
                $parameters["DynamicMemory"]=$true
                if($MinimumMemory){$parameters["MemoryMinimumBytes"]=$MinimumMemory}
                if($MaximumMemory){$parameters["MemoryMaximumBytes"]=$MaximumMemory}
            }

            if($Notes)
            {
                $parameters["Notes"] = $Notes
            }

            if($ProcessorCount)
            {
                $parameters["ProcessorCount"]=$ProcessorCount
            }

            $null = Set-VM @parameters

            ## There's always a NIC added with New-VM
            if($MACAddress)
            {
                Set-VMNetworkAdapter -VMName $Name -StaticMacAddress $MACAddress[0]
            }

            ## Add additional NICs
            for ($i = 1; $i -lt $SwitchName.Count; $i++)
            {
                $addVMNetworkAdapterParams = @{
                    VMName = $Name;
                    SwitchName = $SwitchName[$i];
                }
                if ($MACAddress -and (-not [System.String]::IsNullOrEmpty($MACAddress[$i])))
                {
                    $addVMNetworkAdapterParams['StaticMacAddress'] = $MACAddress[$i];
                }
                Add-VMNetworkAdapter @addVMNetworkAdapterParams
                Write-Verbose -Message ($localizedData.VMPropertySet -f 'NIC', $SwitchName[$i])
            }

            if ($Generation -eq 2) {
                # Secure boot is only applicable to Generation 2 VMs and it defaults to on.
                # Therefore, we only need to explicitly set it to off if specified.
                if ($SecureBoot -eq $false)
                {
                    Set-VMFirmware -VMName $Name -EnableSecureBoot Off
                }
            }

            if ($EnableGuestService)
            {
                Enable-VMIntegrationService -VMName $Name -Name 'Guest Service Interface'
            }
            
            Write-Verbose -Message ($localizedData.VMCreated -f $Name)

            if ($State)
            {
                Set-VMState -Name $Name -State $State -WaitForIP $WaitForIP
                Write-Verbose -Message ($localizedData.VMPropertySet -f 'State', $State)
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
        [parameter(Mandatory)]
        [String]$Name,
        
        # VHD associated with the VM
        [parameter(Mandatory)]
        [String]$VhdPath,
        
        # Virtual switch associated with the VM
        [String[]]$SwitchName,

        # State of the VM
        [AllowNull()]
        [ValidateSet("Running","Paused","Off")]
        [String]$State,

        # Folder where the VM data will be stored
        [String]$Path,

        # Virtual machine generation
        [ValidateRange(1,2)]
        [UInt32]$Generation = 1,

        # Startup RAM for the VM
        [ValidateRange(32MB,17342MB)]
        [UInt64]$StartupMemory,

        # Minimum RAM for the VM. This enables dynamic memory
        [ValidateRange(32MB,17342MB)]
        [UInt64]$MinimumMemory,

        # Maximum RAM for the VM. This enables dynamic memory
        [ValidateRange(32MB,1048576MB)]
        [UInt64]$MaximumMemory,

        # MAC address of the VM
        [String[]]$MACAddress,

        # Processor count for the VM
        [UInt32]$ProcessorCount,

        # Waits for VM to get valid IP address
        [Boolean]$WaitForIP,

        # If specified, shutdowns and restarts the VM as needed for property changes
        [Boolean]$RestartIfNeeded,

        # Should the VM be created or deleted
        [ValidateSet("Present","Absent")]
        [String]$Ensure = "Present",
        [System.String]
        $Notes,

        # Enable secure boot for Generation 2 VMs
        [Boolean]$SecureBoot = $true,

        [Boolean]$EnableGuestService = $false
    )

    #region input validation
    
    # Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw ($localizedData.RoleMissingError -f 'Hyper-V')
    }

    # Check if 1 or 0 VM with name = $name exist
    if((Get-VM -Name $Name -ErrorAction SilentlyContinue).count -gt 1)
    {
       Throw ($localizedData.MoreThanOneVMExistsError -f $Name)
    }
    
    # Check if $VhdPath exist
    if(!(Test-Path $VhdPath))
    {
        Throw ($localizedData.VhdPathDoesNotExistError -f $VhdPath)
    }

    # Check if Minimum memory is less than StartUpmemory
    if($StartupMemory -and $MinimumMemory -and  ($MinimumMemory -gt $StartupMemory))
    {
        Throw ($localizedData.MinMemGreaterThanStartupMemError -f $MinimumMemory, $StartupMemory)
    }
    
    # Check if Minimum memory is greater than Maximummemory
    if($MaximumMemory -and $MinimumMemory -and ($MinimumMemory -gt $MaximumMemory))
    {
        Throw ($localizedData.MinMemGreaterThanMaxMemError -f $MinimumMemory, $MaximumMemory)
    }
    
    # Check if Startup memory is greater than Maximummemory
    if($MaximumMemory -and $StartupMemory -and ($StartupMemory -gt $MaximumMemory))
    {
        Throw ($localizedData.StartUpMemGreaterThanMaxMemError -f $StartupMemory, $MaximumMemory)
    }        

    <#  VM Generation has no direct relation to the virtual hard disk format and cannot be changed
        after the virtual machine has been created. Generation 2 VMs do not support .VHD files.  #>
    if(($Generation -eq 2) -and ($VhdPath.Split('.')[-1] -eq 'vhd'))
    {
        Throw ($localizedData.VhdUnsupportedOnGen2VMError)
    }

    # Check if $Path exist
    if($Path -and !(Test-Path -Path $Path))
    {
        Throw ($localizedData.PathDoesNotExistError -f $Path)
    }

    #endregion

    try
    {
        $vmObj = Get-VM -Name $Name -ErrorAction Stop
        if($Ensure -eq "Present")
        {
            $vhdChain = @(Get-VhdHierarchy -VhdPath ($vmObj.HardDrives[0].Path))
            if($vhdChain -notcontains $VhdPath)
            {
                Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'VhdPath', $VhdPath, ($vhdChain -join ','))
                return $false
            }
            if($state -and ($vmObj.State -ne $State)){return $false}
            if($StartupMemory -and ($vmObj.MemoryStartup -ne $StartupMemory)){return $false}
            if($vmObj.HardDrives.Path -notcontains $VhdPath){return $false}
            for ($i = 0; $i -lt $SwitchName.Count; $i++)
            {
                if ($vmObj.NetworkAdapters[$i].SwitchName -ne $SwitchName[$i])
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'SwitchName', $SwitchName[$i], $vmObj.NetworkAdapters[$i].SwitchName)
                    return $false
                }
            }
            if($state -and ($vmObj.State -ne $State)){return $false}
            if($StartupMemory -and ($vmObj.MemoryStartup -ne $StartupMemory)){return $false}
            for ($i = 0; $i -lt $MACAddress.Count; $i++)
            { 
                if ($vmObj.NetworkAdapters[$i].MACAddress -ne $MACAddress[$i])
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'MACAddress', $MACAddress[$i], $vmObj.NetworkAdapters[$i].MACAddress)
                    return $false
                }
            }

            ## $Generation always exists, only check if parameter has been explicitly specified
            if($PSBoundParameters.ContainsKey('Generation') -and ($Generation -ne $vmObj.Generation)){return $false}

            if($ProcessorCount -and ($vmObj.ProcessorCount -ne $ProcessorCount)){return $false}
            if($MaximumMemory -and ($vmObj.MemoryMaximum -ne $MaximumMemory)){return $false}
            if($MinimumMemory -and ($vmObj.MemoryMinimum -ne $MinimumMemory)){return $false}

            if($vmObj.Generation -eq 2) {
                $vmSecureBoot = Test-VMSecureBoot -Name $Name
                if ($SecureBoot -ne $vmSecureBoot)
                {
                    Write-Verbose -Message ($localizedData.VMPropertyShouldBe -f 'SecureBoot', $SecureBoot, $vmSecureBoot)
                    return $false
                }
            }
            if (($vmObj | Get-VMIntegrationService -Name 'Guest Service Interface').Enabled -ne $EnableGuestService) {return $false}
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

<# Returns VM VHDs, including snapshots and differencing disks #>
function Get-VhdHierarchy
{
    param(
        [Parameter(Mandatory)]
        [System.String] $VhdPath
    )
    
    $vmVhdPath = Get-VHD -Path $VhdPath
    Write-Output -InputObject $vmVhdPath.Path
    while(-not [System.String]::IsNullOrEmpty($vmVhdPath.ParentPath))
    {
        $vmVhdPath.ParentPath
        $vmVhdPath = (Get-VHD -Path $vmVhdPath.ParentPath)
    }
}

function Set-VMState
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet("Running","Paused","Off")]
        [String]$State,

        [Boolean]$WaitForIP
    )

    switch ($State)
    {
        'Running' {
            $oldState = (Get-VM -Name $Name).State
            # If VM is in paused state, use resume-vm to make it running
            if($oldState -eq "Paused"){Resume-VM -Name $Name}
            # If VM is Off, use start-vm to make it running
            elseif ($oldState -eq "Off"){Start-VM -Name $Name}
            
            if($WaitForIP) { Get-VMIPAddress -Name $Name -Verbose }
        }
        'Paused' {if($oldState -ne 'Off'){Suspend-VM -Name $Name}}
        'Off' {Stop-VM -Name $Name -Force -WarningAction SilentlyContinue}
    }
}

function Change-VMMACAddress
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [String]$MACAddress,

        [Parameter(Mandatory)]
        [Int]$NICIndex,

        [Boolean]$WaitForIP,

        [Boolean]$RestartIfNeeded
    )
    $vmObj = Get-VM -Name $Name
    $originalState = $vmObj.state
    if($originalState -ne "Off" -and $RestartIfNeeded)
    { 
        Set-VMState -Name $Name -State Off
        $vmObj.NetworkAdapters[$NICIndex] | Set-VMNetworkAdapter -StaticMacAddress $MACAddress

        # Can not move a off VM to paused, but only to running state
        if($originalState -eq "Running")
        {
            Set-VMState -Name $Name -State Running -WaitForIP $WaitForIP
        }
        
        # Cannot make a paused VM to go back to Paused state after turning Off
        if($originalState -eq "Paused")
        {
            Write-Warning -Message ($localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif($originalState -eq "Off")
    {
        $vmObj.NetworkAdapters[$NICIndex] | Set-VMNetworkAdapter -StaticMacAddress $MACAddress
        Write-Verbose -Message ($localizedData.VMPropertySet -f 'MACAddress', $MACAddress)
    }
    else
    {
        Write-Error -Message ($localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmObj.State)
    }
}

function Change-VMProperty
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [String]$VMCommand,

        [Parameter(Mandatory)]
        [Hashtable]$ChangeProperty,

        [Boolean]$WaitForIP,

        [Boolean]$RestartIfNeeded
    )

    $vmObj = Get-VM -Name $Name
    $originalState = $vmObj.state
    if($originalState -ne "Off" -and $RestartIfNeeded)
    { 
        Set-VMState -Name $Name -State Off
        &$VMCommand -Name $Name @ChangeProperty

        # Can not move a off VM to paused, but only to running state
        if($originalState -eq "Running")
        {
            Set-VMState -Name $Name -State Running -WaitForIP $WaitForIP
        }

        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)

        # Cannot make a paused VM to go back to Paused state after turning Off
        if($originalState -eq "Paused")
        {
            Write-Warning -Message ($localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif($originalState -eq "Off")
    {
        &$VMCommand -Name $Name @ChangeProperty 
        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)
    }
    else
    {
        Write-Error -Message ($localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmObj.State)
    }
}

# The 'Change-VMProperty' method cannot be used as it's hard-coded to use the -Name
# parameter and unfortunately, the Set-VMFirmware cmdlet uses the -VMName parameter instead!
function Change-VMSecureBoot
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,

        [Boolean]$SecureBoot,

        [Boolean]$RestartIfNeeded
    )

    $vmObj = Get-VM -Name $Name
    $originalState = $vmObj.state
    if($originalState -ne "Off" -and $RestartIfNeeded)
    { 
        Set-VMState -Name $Name -State Off
        if ($SecureBoot)
        {
            Set-VMFirmware -VMName $Name -EnableSecureBoot On
        }
        else {
            Set-VMFirmware -VMName $Name -EnableSecureBoot Off
        }

        # Can not move a off VM to paused, but only to running state
        if($originalState -eq "Running")
        {
            Set-VMState -Name $Name -State Running -WaitForIP $true
        }

        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)

        # Cannot make a paused VM to go back to Paused state after turning Off
        if($originalState -eq "Paused")
        {
            Write-Warning -Message ($localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif($originalState -eq "Off")
    {
        if ($SecureBoot)
        {
            Set-VMFirmware -VMName $Name -EnableSecureBoot On
        }
        else {
            Set-VMFirmware -VMName $Name -EnableSecureBoot Off
        }
    }
    else
    {
        Write-Error -Message ($localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmObjState)
    }
}

function Test-VMSecureBoot
{
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )
    $vm = Get-VM -Name $Name;
    return (Get-VMFirmware -VM $vm).SecureBoot -eq 'On';
}

function Get-VMIPAddress
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Name
    )

    while((Get-VMNetworkAdapter -VMName $Name).ipaddresses.count -lt 2)
    {
        Write-Verbose -Message ($localizedData.WaitingForVMIPAddress -f $Name)
        Start-Sleep -Seconds 3;
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource

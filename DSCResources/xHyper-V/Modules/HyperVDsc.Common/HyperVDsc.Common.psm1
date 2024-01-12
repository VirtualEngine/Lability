$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../DscResource.Common'

Import-Module -Name $script:dscResourceCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
    Sets one or more virtual machine properties, powering the VM
    off if required.

    .PARAMETER Name
    Name of the virtual machine to apply the changes to.

    .PARAMETER VMName
    Name of the virtual machine to apply the changes to.

    .PARAMETER VMCommand
    The Hyper-V cmdlet name to call to enact the changes.

    .PARAMETER ChangeProperty
    The collection of cmdlet parameter names and values to pass to the command.

    .PARAMETER WaitForIP
    Waits for the virtual machine to report an IP address when transitioning
    into a running state.

    .PARAMETER RestartIfNeeded
    Power cycle the virtual machine if changes are required.
#>
function Set-VMProperty
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'VMName')]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VMCommand,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $ChangeProperty,

        [Parameter()]
        [System.Boolean]
        $WaitForIP,

        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded
    )

    if ($PSBoundParameters.ContainsKey('VMName'))
    {
        # Add the -Name property to the ChangeProperty hashtable for splatting
        $ChangeProperty['VMName'] = $VMName

        # Set the common parameters for splatting against Get-VM and Set-VMState
        $vmCommonProperty = @{
            Name = $VMName
        }

        # Ensure that the name parameter is set for verbose messages
        $Name = $VMName
    }
    else
    {
        # Add the -Name property to the ChangeProperty hashtable for splatting
        $ChangeProperty['Name'] = $Name

        # Set the common parameters for splatting against Get-VM and Set-VMState
        $vmCommonProperty = @{
            Name = $Name
        }
    }

    $vmObject = Get-VM @vmCommonProperty
    $vmOriginalState = $vmObject.State

    if ($vmOriginalState -ne 'Off' -and $RestartIfNeeded)
    {
        # Turn the vm off to make changes
        Set-VMState @vmCommonProperty -State Off

        Write-Verbose -Message ($script:localizedData.UpdatingVMProperties -f $Name)
        # Make changes using the passed hashtable
        & $VMCommand @ChangeProperty

        # Cannot move an off VM to a paused state - only to running state
        if ($vmOriginalState -eq 'Running')
        {
            Set-VMState @vmCommonProperty -State Running -WaitForIP $WaitForIP
        }

        Write-Verbose -Message ($script:localizedData.VMPropertiesUpdated -f $Name)

        # Cannot restore a vm to a paused state
        if ($vmOriginalState -eq 'Paused')
        {
            Write-Warning -Message ($script:localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif ($vmOriginalState -eq 'Off')
    {
        Write-Verbose -Message ($script:localizedData.UpdatingVMProperties -f $Name)
        & $VMCommand @ChangeProperty
        Write-Verbose -Message ($script:localizedData.VMPropertiesUpdated -f $Name)
    }
    else
    {
        $errorMessage = $script:localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmOriginalState
        New-InvalidOperationException -Message $errorMessage
    }
} #end function

<#
    .SYNOPSIS
    Sets one or more virtual machine properties, powering the VM
    off if required.

    .PARAMETER Name
    Name of the virtual machine to apply the changes to.

    .PARAMETER State
    The target power state of the virtual machine.

    .PARAMETER ChangeProperty
    The collection of cmdlet parameter names and values to pass to the command.

    .PARAMETER WaitForIP
    Waits for the virtual machine to be report an IP address when transitioning
    into a running state.
#>
function Set-VMState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('VMName')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Running','Paused','Off')]
        [System.String]
        $State,

        [Parameter()]
        [System.Boolean]
        $WaitForIP
    )

    switch ($State)
    {
        'Running' {
            $vmCurrentState = (Get-VM -Name $Name).State
            if ($vmCurrentState -eq 'Paused')
            {
                # If VM is in paused state, use resume-vm to make it running
                Write-Verbose -Message ($script:localizedData.ResumingVM -f $Name)
                Resume-VM -Name $Name
            }
            elseif ($vmCurrentState -eq 'Off')
            {
                # If VM is Off, use start-vm to make it running
                Write-Verbose -Message ($script:localizedData.StartingVM -f $Name)
                Start-VM -Name $Name
            }

            if ($WaitForIP)
            {
                Wait-VMIPAddress -Name $Name -Verbose
            }
        }
        'Paused' {
            if ($vmCurrentState -ne 'Off')
            {
                Write-Verbose -Message ($script:localizedData.SuspendingVM -f $Name)
                Suspend-VM -Name $Name
            }
        }
        'Off' {
            if ($vmCurrentState -ne 'Off')
            {
                Write-Verbose -Message ($script:localizedData.StoppingVM -f $Name)
                Stop-VM -Name $Name -Force -WarningAction SilentlyContinue
            }
        }
    }
} #end function

<#
    .SYNOPSIS
    Waits for a virtual machine to be assigned an IP address.

    .PARAMETER Name
    Name of the virtual machine to apply the changes to.

    .PARAMETER Timeout
    Number of seconds to wait before timing out. Defaults to 300 (5 minutes).
#>
function Wait-VMIPAddress
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('VMName')]
        [System.String]
        $Name,

        [Parameter()]
        [System.Int32]
        $Timeout = 300
    )

    [System.Int32] $elapsedSeconds = 0
    while ((Get-VMNetworkAdapter -VMName $Name).IpAddresses.Count -lt 2)
    {
        Write-Verbose -Message ($script:localizedData.WaitingForVMIPAddress -f $Name)
        Start-Sleep -Seconds 3

        $elapsedSeconds += 3
        if ($elapsedSeconds -gt $Timeout)
        {
            $errorMessage = $script:localizedData.WaitForVMIPAddressTimeoutError -f $Name, $Timeout

            New-ObjectNotFoundException -Message $errorMessage
        }
    }
} #end function

<#
    .SYNOPSIS
    Converts a number of seconds, minutes, hours or days into a System.TimeSpan object.

    .PARAMETER TimeInterval
    The total number of seconds, minutes, hours or days to convert.

    .PARAMETER TimeSpanType
    Convert using specified interval type.
#>
function ConvertTo-TimeSpan
{
    [CmdletBinding()]
    [OutputType([System.TimeSpan])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $TimeInterval,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Seconds','Minutes','Hours','Days')]
        [System.String]
        $TimeIntervalType
    )

    $newTimeSpanParams = @{ }
    switch ($TimeIntervalType)
    {
        'Seconds' { $newTimeSpanParams['Seconds'] = $TimeInterval }
        'Minutes' { $newTimeSpanParams['Minutes'] = $TimeInterval }
        'Hours' { $newTimeSpanParams['Hours'] = $TimeInterval }
        'Days' { $newTimeSpanParams['Days'] = $TimeInterval }
    }
    return (New-TimeSpan @newTimeSpanParams)
} #end function ConvertTo-TimeSpan

<#
    .SYNOPSIS
    Converts a System.TimeSpan into the number of seconds, minutes, hours or days.

    .PARAMETER TimeSpan
    TimeSpan to convert into an integer

    .PARAMETER TimeSpanType
    Convert timespan into the total number of seconds, minutes, hours or days.
#>
function ConvertFrom-TimeSpan
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.TimeSpan]
        $TimeSpan,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Seconds','Minutes','Hours','Days')]
        [System.String]
        $TimeSpanType
    )

    switch ($TimeSpanType)
    {
        'Seconds' { return $TimeSpan.TotalSeconds -as [System.UInt32] }
        'Minutes' { return $TimeSpan.TotalMinutes -as [System.UInt32] }
        'Hours' { return $TimeSpan.TotalHours -as [System.UInt32] }
        'Days' { return $TimeSpan.TotalDays -as [System.UInt32] }
    }
} #end function ConvertFrom-TimeSpan

<#
    .SYNOPSIS
    Helper function for retrieving a virtual machine, ensuring only one VM is resolved

    .PARAMETER VMName
    Name of the Hyper-V virtual machine to return
#>
function Get-VMHyperV
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    # Check if 1 or 0 VM with name = $name exist
    if ($vm.count -gt 1)
    {
        $errorMessage = $script:localizedData.MoreThanOneVMExistsError -f $VMName
        New-InvalidResultException -Message $errorMessage
    }

    return $vm
} #end function Get-VMHyperV

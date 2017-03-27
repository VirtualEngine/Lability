#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename HyperVCommon.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    #fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename HyperVCommon.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
    .SYNOPSIS
    Throws an InvalidOperation custom exception.

    .PARAMETER ErrorId
    The error Id of the exception.

    .PARAMETER ErrorMessage
    The error message text to set in the exception.
#>
function New-InvalidOperationError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $exception = New-Object -TypeName System.InvalidOperationException `
        -ArgumentList $ErrorMessage
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $ErrorId, $errorCategory, $null
    throw $errorRecord
} # end function New-InvalidOperationError


<#
    .SYNOPSIS
    Throws an InvalidArgument custom exception.

    .PARAMETER ErrorId
    The error Id of the exception.

    .PARAMETER ErrorMessage
    The error message text to set in the exception.
#>
function New-InvalidArgumentError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $exception = New-Object -TypeName System.ArgumentException `
        -ArgumentList $ErrorMessage
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $ErrorId, $errorCategory, $null
    throw $errorRecord
} # end function New-InvalidArgumentError


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
    Waits for the virtual machine to be report an IP address when transitioning
    into a running state.

    .PARAMETER RestartIfNeeded
    Power cycle the virtual machine if changes are required.
#>
function Set-VMProperty
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Name')]
        [System.String] $Name,

        [Parameter(Mandatory, ParameterSetName = 'VMName')]
        [System.String] $VMName,

        [Parameter(Mandatory)]
        [System.String] $VMCommand,

        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $ChangeProperty,

        [Parameter()]
        [System.Boolean] $WaitForIP,

        [Parameter()]
        [System.Boolean] $RestartIfNeeded
    )

    if ($PSBoundParameters.ContainsKey('VMName'))
    {
        ## Add the -Name property to the ChangeProperty hashtable for splatting
        $ChangeProperty['VMName'] = $VMName

        ## Set the common parameters for splatting against Get-VM and Set-VMState
        $vmCommonProperty = @{ Name = $VMName; }

        ## Ensure that the name parameter is set for verbose messages
        $Name = $VMName
    }
    else
    {
        ## Add the -Name property to the ChangeProperty hashtable for splatting
        $ChangeProperty['Name'] = $Name

        ## Set the common parameters for splatting against Get-VM and Set-VMState
        $vmCommonProperty = @{ Name = $Name; }
    }

    $vmObject = Get-VM @vmCommonProperty
    $vmOriginalState = $vmObject.State

    if ($vmOriginalState -ne 'Off' -and $RestartIfNeeded)
    {
        ## Turn the vm off to make changes
        Set-VMState @vmCommonProperty -State Off

        Write-Verbose -Message ($localizedData.UpdatingVMProperties -f $Name)
        ## Make changes using the passed hashtable
        & $VMCommand @ChangeProperty

        # Cannot move an off VM to a paused state - only to running state
        if ($vmOriginalState -eq 'Running')
        {
            Set-VMState @vmCommonProperty -State Running -WaitForIP $WaitForIP
        }

        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)

        # Cannot restore a vm to a paused state
        if ($vmOriginalState -eq 'Paused')
        {
            Write-Warning -Message ($localizedData.VMStateWillBeOffWarning -f $Name)
        }
    }
    elseif ($vmOriginalState -eq 'Off')
    {
        Write-Verbose -Message ($localizedData.UpdatingVMProperties -f $Name)
        & $VMCommand @ChangeProperty
        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $Name)
    }
    else
    {
        $errorMessage = $localizedData.CannotUpdatePropertiesOnlineError -f $Name, $vmOriginalState
        New-InvalidOperationError -ErrorId RestartRequired -ErrorMessage $errorMessage
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
        [Parameter(Mandatory)]
        [Alias('VMName')]
        [System.String] $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Running','Paused','Off')]
        [System.String] $State,

        [System.Boolean] $WaitForIP
    )

    switch ($State)
    {
        'Running' {
            $vmCurrentState = (Get-VM -Name $Name).State
            if ($vmCurrentState -eq "Paused")
            {
                # If VM is in paused state, use resume-vm to make it running
                Write-Verbose -Message ($localizedData.ResumingVM -f $Name)
                Resume-VM -Name $Name
            }
            elseif ($vmCurrentState -eq 'Off')
            {
                # If VM is Off, use start-vm to make it running
                Write-Verbose -Message ($localizedData.StartingVM -f $Name)
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
                Write-Verbose -Message ($localizedData.SuspendingVM -f $Name)
                Suspend-VM -Name $Name
            }
        }
        'Off' {
            if ($vmCurrentState -ne 'Off')
            {
                Write-Verbose -Message ($localizedData.StoppingVM -f $Name)
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
#>
function Wait-VMIPAddress
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Alias('VMName')]
        [System.String] $Name
    )

    while ((Get-VMNetworkAdapter -VMName $Name).IpAddresses.Count -lt 2)
    {
        Write-Verbose -Message ($localizedData.WaitingForVMIPAddress -f $Name)
        Start-Sleep -Seconds 3;
    }
} #end function


<#
    .SYNOPSIS
    Ensures that the specified PowerShell module(s) are installed.

    .PARAMETER Name
    Name of the PowerShell module to check is installed.
#>
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String[]] $Name
    )

    if (-not (Get-Module -Name $Name -ListAvailable ))
    {
        $errorMessage = $localizedData.RoleMissingError -f $Name
        New-InvalidOperationError -ErrorId MissingRole -ErrorMessage $errorMessage
    }

} #end function

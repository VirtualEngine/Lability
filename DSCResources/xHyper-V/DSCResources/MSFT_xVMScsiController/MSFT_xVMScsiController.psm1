#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMScsiController.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    # fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMScsiController.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

# Import the common HyperV functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\HyperVCommon\HyperVCommon.psm1' )

<#
    .SYNOPSIS
    Returns the current status of the VM SCSI controller.

    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller status is to be fetched.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the hard disk drive is to be set.
    If not specified, the controller number defaults to 0.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0, 1, 2, 3)]
        [System.UInt32]
        $ControllerNumber
    )

    Assert-Module -Name 'Hyper-V'

    $controller = Get-VMScsiController -VMName $VMName -ControllerNumber $ControllerNumber
    if ($null -eq $controller)
    {
        Write-Verbose -Message ($localizedData.ControllerNotFound -f $ControllerNumber, $VMName)
        $ensure = 'Absent'
    }
    else
    {
        Write-Verbose -Message ($localizedData.ControllerFound -f $ControllerNumber, $VMName)
        $ensure = 'Present'
    }

    return @{
        VMName           = $Controller.VMName
        ControllerNumber = $Controller.ControllerNumber
        RestartIfNeeded  = $false
        Ensure           = $ensure
    }
}

<#
    .SYNOPSIS
    Tests the state of a VM SCSI controller.

    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller is to be tested.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the hard disk drive is to be set.
    If not specified, the controller number defaults to 0.

    .PARAMETER RestartIfNeeded
    Specifies if the VM should be restarted if needed for property changes.

    .PARAMETER Ensure
    Specifies if the SCSI controller should exist or not. Default to Present.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0, 1, 2, 3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $null = $PSBoundParameters.Remove('RestartIfNeeded')
    $resource = Get-TargetResource -VMName $VMName -ControllerNumber $ControllerNumber

    $isCompliant = $true
    foreach ($key in $resource.Keys)
    {
        Write-Verbose -Message ($localizedData.ComparingParameter -f $key,
                                                                    $PSBoundParameters[$key],
                                                                    $resource[$key])
        $isCompliant = $isCompliant -and ($PSBoundParameters[$key] -eq $resource[$key])
    }

    return $isCompliant
}

<#
    .SYNOPSIS
    Manipulates the state of a VM SCSI controller.

    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller is to be manipulated.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the hard disk drive is to be set.
    If not specified, the controller number defaults to 0.

    .PARAMETER RestartIfNeeded
    Specifies if the VM should be restarted if needed for property changes.

    .PARAMETER Ensure
    Specifies if the SCSI controller should exist or not. Defaults to Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0, 1, 2, 3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [System.Boolean]
        $RestartIfNeeded,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -Name 'Hyper-V'

    # Getting the state of the VM so we can restore it later
    $existingVmState = (Get-VMHyperV -VMName $VMName).State

    if ((-not $RestartIfNeeded) -and ($existingVmState -ne 'Off'))
    {
        $errorMessage = $localizedData.CannotUpdateVmOnlineError -f $VMName
        New-InvalidOperationError -ErrorId InvalidState -ErrorMessage $errorMessage
    }

    [System.Int32] $scsiControllerCount = @(Get-VMScsiController -VMName $VMName).Count
    if ($Ensure -eq 'Present')
    {
        if ($scsiControllerCount -lt $ControllerNumber)
        {
            <#
            All intermediate controllers should be present on the system as we cannot create
            a controller at a particular location. For example, we cannot explicitly create
            controller #2 - it will only be controller #2 if controllers #0 and #1 are already
            added/present in the VM.
            #>
            $errorMessage = $localizedData.CannotAddScsiControllerError -f $ControllerNumber
            New-InvalidArgumentError -ErrorId InvalidController -ErrorMessage $errorMessage
        }

        Set-VMState -Name $VMName -State 'Off'
        Write-Verbose -Message ($localizedData.AddingController -f $scsiControllerCount)
        Add-VMScsiController -VMName $VMName
    }
    else
    {
        if ($scsiControllerCount -ne ($ControllerNumber +1))
        {
            <#
                All intermediate controllers should be present on the system. Whilst we can remove
                a controller at a particular location, all remaining controller numbers may be
                reordered. For example, if we remove controller at position #1, then a controller
                that was at position #2 will become controller number #1.
            #>
            $errorMessage = $localizedData.CannotRemoveScsiControllerError -f $ControllerNumber
            New-InvalidArgumentError -ErrorId InvalidController -ErrorMessage $errorMessage
        }

        Set-VMState -Name $VMName -State 'Off'
        Write-Verbose -Message ($localizedData.CheckingExistingDisks -f $ControllerNumber)
        $controller = Get-VMScsiController -VMName $VmName -ControllerNumber $ControllerNumber

        foreach ($drive in $controller.Drives)
        {
            $warningMessage = $localizedData.RemovingDiskWarning -f $drive.Path, $ControllerNumber
            Write-Warning -Message $warningMessage
            Remove-VMHardDiskDrive -VMHardDiskDrive $drive
        }

        Write-Verbose -Message ($localizedData.RemovingController -f $ControllerNumber, $VMName)
        Remove-VMScsiController -VMScsiController $controller
    }

    # Restore the previous state
    Set-VMState -Name $VMName -State $existingVmState
}

Export-ModuleMember -Function *-TargetResource

$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/DscResource.Common'
$script:hyperVDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/HyperVDsc.Common'

Import-Module -Name $script:dscResourceCommonModulePath
Import-Module -Name $script:hyperVDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
    Returns the current status of the VM hard disk drive.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose hard disk drive status is to be fetched.
    .PARAMETER Path
    Specifies the full path of the VHD file linked to the hard disk drive.
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
        [System.String]
        $Path
    )

    Assert-Module -ModuleName 'Hyper-V'

    $hardDiskDrive = Get-VMHardDiskDrive -VMName $VMName -ErrorAction Stop |
        Where-Object -FilterScript { $_.Path -eq $Path }

    if ($null -eq $hardDiskDrive)
    {
        Write-Verbose -Message ($script:localizedData.DiskNotFound -f $Path, $VMName)
        $ensure = 'Absent'
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.DiskFound -f $Path, $VMName)
        $ensure = 'Present'
    }

    return @{
        VMName             = $VMName
        Path               = $hardDiskDrive.Path
        ControllerType     = $hardDiskDrive.ControllerType
        ControllerNumber   = $hardDiskDrive.ControllerNumber
        ControllerLocation = $hardDiskDrive.ControllerLocation
        Ensure             = $ensure
    }
}

<#
    .SYNOPSIS
    Tests the state of a VM hard disk drive.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose hard disk drive is to be tested.
    .PARAMETER Path
    Specifies the full path of the VHD file to be tested.
    .PARAMETER ControllerType
    Specifies the type of controller to which the the hard disk drive is to be set (IDE/SCSI).
    Default to SCSI.
    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the hard disk drive is to be set.
    If not specified, the controller number defaults to 0.
    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the hard disk drive is to be
    set. If not specified, the controller location defaults to 0.
    .PARAMETER Ensure
    Specifies if the hard disk drive should exist or not. Defaults to Present.
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
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('IDE', 'SCSI')]
        [System.String]
        $ControllerType = 'SCSI',

        [Parameter()]
        [ValidateSet(0, 1, 2, 3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [ValidateRange(0, 63)]
        [System.UInt32]
        $ControllerLocation,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $resource = Get-TargetResource -VMName $VMName -Path $Path

    # throw exception when the ControllerNumber or ControllerLocation are out of bounds for IDE
    if ($ControllerType -eq 'IDE' -and ($ControllerNumber -gt 1 -or $ControllerLocation -gt 1))
    {
        $errorMessage = $script:localizedData.IdeLocationError -f $ControllerNumber, $ControllerLocation

        New-InvalidArgumentException -ArgumentName 'ControllerType' -Message $errorMessage
    }

    $isCompliant = $true
    foreach ($key in $PSBoundParameters.Keys)
    {
        # Only check passed parameter values
        if ($resource.ContainsKey($key))
        {
            Write-Verbose -Message ($script:localizedData.ComparingParameter -f $key,
                $PSBoundParameters[$key],
                $resource[$key])
            $isCompliant = $isCompliant -and ($PSBoundParameters[$key] -eq $resource[$key])
        }
    }
    return $isCompliant
}

<#
    .SYNOPSIS
    Tests the state of a VM hard disk drive.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose hard disk drive is to be tested.
    .PARAMETER Path
    Specifies the full path of the VHD file to be tested.
    .PARAMETER ControllerType
    Specifies the type of controller to which the the hard disk drive is to be set (IDE/SCSI).
    Default to SCSI.
    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the hard disk drive is to be set.
    If not specified, the controller number defaults to 0.
    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the hard disk drive is to be
    set. If not specified, the controller location defaults to 0.
    .PARAMETER Ensure
    Specifies if the hard disk drive should exist or not. Defaults to Present.
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
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('IDE', 'SCSI')]
        [System.String]
        $ControllerType = 'SCSI',

        [Parameter()]
        [ValidateSet(0, 1, 2, 3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [ValidateRange(0, 63)]
        [System.UInt32]
        $ControllerLocation,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'Hyper-V'

    $hardDiskDrive = Get-VMHardDiskDrive -VMName $VMName |
        Where-Object -FilterScript { $_.Path -eq $Path }

    if ($Ensure -eq 'Present')
    {
        $null = $PSBoundParameters.Remove('Ensure')

        Write-Verbose -Message ($script:localizedData.CheckingDiskIsAttached)
        if ($hardDiskDrive)
        {
            Write-Verbose -Message ($script:localizedData.DiskFound -f $Path, $VMName)
            $null = $PSBoundParameters.Remove('VMName')
            $null = $PSBoundParameters.Remove('Path')
            # As the operation is a move, we must use ToController instead of Controller
            if ($PSBoundParameters.ContainsKey('ControllerType'))
            {
                $null = $PSBoundParameters.Remove('ControllerType')
                $null = $PSBoundParameters.Add('ToControllerType', $ControllerType)
            }
            if ($PSBoundParameters.ContainsKey('ControllerNumber'))
            {
                $null = $PSBoundParameters.Remove('ControllerNumber')
                $null = $PSBoundParameters.Add('ToControllerNumber', $ControllerNumber)
            }
            if ($PSBoundParameters.ContainsKey('ControllerLocation'))
            {
                $null = $PSBoundParameters.Remove('ControllerLocation')
                $null = $PSBoundParameters.Add('ToControllerLocation', $ControllerLocation)
            }
            $null = $hardDiskDrive | Set-VMHardDiskDrive @PSBoundParameters
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.CheckingExistingDiskLocation)

            $getVMHardDiskDriveParams = @{
                VMName             = $VMName
                ControllerType     = $ControllerType
                ControllerNumber   = $ControllerNumber
                ControllerLocation = $ControllerLocation
            }

            $existingHardDiskDrive = Get-VMHardDiskDrive @getVMHardDiskDriveParams

            if ($null -ne $existingHardDiskDrive)
            {
                $errorMessage = $script:localizedData.DiskPresentError -f $ControllerNumber, $ControllerLocation

                New-InvalidResultException -Message $errorMessage
            }

            Write-Verbose -Message ($script:localizedData.AddingDisk -f $Path, $VMName)
            $null = Add-VMHardDiskDrive @PSBoundParameters
        }
    }
    else
    {
        # We must ensure that the disk is absent
        if ($hardDiskDrive)
        {
            Write-Verbose -Message ($script:localizedData.RemovingDisk -f $Path, $VMName)
            $null = $hardDiskDrive | Remove-VMHardDiskDrive
        }
        else
        {
            Write-Warning -Message ($script:localizedData.DiskNotFound -f $Path, $VMName)
        }
    }
}

Export-ModuleMember -Function *-TargetResource

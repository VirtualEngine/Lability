$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/DscResource.Common'
$script:hyperVDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/HyperVDsc.Common'

Import-Module -Name $script:dscResourceCommonModulePath
Import-Module -Name $script:hyperVDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
    Returns the current status of the VM DVD Drive.

    .PARAMETER VMName
    Specifies the name of the virtual machine to which the DVD drive is to be added.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the DVD drive is to be added.

    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the DVD drive is to be added.
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
        [System.UInt32]
        $ControllerNumber,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $ControllerLocation
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingVMDVDDriveMessage `
                    -f $VMName, $ControllerNumber, $ControllerLocation)
        ) -join '' )

    Test-ParameterValid @PSBoundParameters

    $dvdDrive = Get-VMDvdDrive @PSBoundParameters

    if ($dvdDrive)
    {
        $returnValue = @{
            VMName             = $VMName
            ControllerLocation = $ControllerLocation
            ControllerNumber   = $ControllerNumber
            Path               = $dvdDrive.Path
            Ensure             = 'Present'
        }
    }
    else
    {
        $returnValue = @{
            VMName             = $VMName
            ControllerLocation = $ControllerLocation
            ControllerNumber   = $ControllerNumber
            Path               = ''
            Ensure             = 'Absent'
        }
    } # if

    $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
    Adds, removes or changes the mounted ISO on a VM DVD Drive.

    .PARAMETER VMName
    Specifies the name of the virtual machine to which the DVD drive is to be added.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the DVD drive is to be added.

    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the DVD drive is to be added.

    .PARAMETER Path
    Specifies the full path to the virtual hard disk file or physical hard disk volume for the
    added DVD drive.

    .PARAMETER Ensure
    Specifies if the DVD Drive should exist or not.
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
        [System.UInt32]
        $ControllerLocation,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingVMDVDDriveMessage `
                    -f $VMName, $ControllerNumber, $ControllerLocation)
        ) -join '' )

    $null = $PSBoundParameters.Remove('Path')
    $null = $PSBoundParameters.Remove('Ensure')

    # Get the current status of the VM DVD Drive
    $dvdDrive = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        # The DVD Drive should exist
        if ($dvdDrive.Ensure -eq 'Present')
        {
            # The DVD Drive already exists
            if (-not [System.String]::IsNullOrWhiteSpace($Path) `
                    -and ($Path -ne $dvdDrive.Path))
            {
                # The current path assigned to the DVD Drive needs to be changed.
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.VMDVDDriveChangePathMessage) `
                            -f $VMName, $ControllerNumber, $ControllerLocation, $Path `
                    ) -join '' )

                Set-VMDvdDrive @PSBoundParameters -Path $Path
            }
        }
        else
        {
            # The DVD Drive does not exist but should. Change required.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.VMDVDDriveAddMessage) `
                        -f $VMName, $ControllerNumber, $ControllerLocation, $Path `
                ) -join '' )

            if (-not [System.String]::IsNullOrWhiteSpace($Path))
            {
                $PSBoundParameters.Add('Path', $Path)
            } # if

            Add-VMDvdDrive @PSBoundParameters
        } # if
    }
    else
    {
        # The DVD Drive should not exist
        if ($dvdDrive.Ensure -eq 'Present')
        {
            # The DVD Drive does exist, but should not. Change required.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.VMDVDDriveRemoveMessage) `
                        -f $VMName, $ControllerNumber, $ControllerLocation `
                ) -join '' )

            Remove-VMDvdDrive @PSBoundParameters
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
    Tests the state of a VM DVD Drive and the mounted ISO.

    .PARAMETER VMName
    Specifies the name of the virtual machine to which the DVD drive is to be added.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the DVD drive is to be added.

    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the DVD drive is to be added.

    .PARAMETER Path
    Specifies the full path to the virtual hard disk file or physical hard disk volume for the
    added DVD drive.

    .PARAMETER Ensure
    Specifies if the DVD Drive should exist or not.
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
        [System.UInt32]
        $ControllerLocation,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingVMDVDDriveMessage `
                    -f $VMName, $ControllerNumber, $ControllerLocation)
        ) -join '' )

    $null = $PSBoundParameters.Remove('Path')
    $null = $PSBoundParameters.Remove('Ensure')

    # Get the current status of the VM DVD Drive
    $dvdDrive = Get-TargetResource @PSBoundParameters

    # Flag to signal whether settings are correct
    [System.Boolean] $desiredConfigurationMatch = $true

    if ($Ensure -eq 'Present')
    {
        # The DVD Drive should exist
        if ($dvdDrive.Ensure -eq 'Present')
        {
            # The DVD Drive already exists
            if (-not [System.String]::IsNullOrWhiteSpace($Path) `
                    -and ($Path -ne $dvdDrive.Path))
            {
                # The current path assigned to the DVD drive is wrong. Change required.
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.VMDVDDriveExistsAndShouldPathMismatchMessage) `
                            -f $VMName, $ControllerNumber, $ControllerLocation, $Path, $dvdDrive.Path `
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
            else
            {
                # The DVD drive exists and should. Change not required.
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.VMDVDDriveExistsAndShouldMessage) `
                            -f $VMName, $ControllerNumber, $ControllerLocation, $Path `
                    ) -join '' )
            } # if
        }
        else
        {
            # The DVD Drive does not exist but should. Change required.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.VMDVDDriveDoesNotExistButShouldMessage) `
                        -f $VMName, $ControllerNumber, $ControllerLocation `
                ) -join '' )

            $desiredConfigurationMatch = $false
        } # if
    }
    else
    {
        # The DVD Drive should not exist
        if ($dvdDrive.Ensure -eq 'Present')
        {
            # The DVD Drive does exist, but should not. Change required.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.VMDVDDriveDoesExistButShouldNotMessage) `
                        -f $VMName, $ControllerNumber, $ControllerLocation `
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The DVD Drive does not exist and should not. Change not required.
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.VMDVDDriveDoesNotExistAndShouldNotMessage) `
                        -f $VMName, $ControllerNumber, $ControllerLocation `
                ) -join '' )
        } # if
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
    Validates that the parameters passed are valid. If the parameter combination
    is invalid then an exception will be thrown. The following items are validated:
    - The VM exists.
    - A disk mount point at the controller number/location exists.
    - A hard disk is not already mounted at the controller number/location.
    - The Path if required is valid.

    .PARAMETER VMName
    Specifies the name of the virtual machine to which the DVD drive is to be added.

    .PARAMETER ControllerNumber
    Specifies the number of the controller to which the DVD drive is to be added.

    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the DVD drive is to be added.

    .PARAMETER Path
    Specifies the full path to the virtual hard disk file or physical hard disk volume for the
    added DVD drive.

    .PARAMETER Ensure
    Specifies if the DVD Drive should exist or not.

    .OUTPUTS
    Returns true if the parameters are valid, but will throw a specific error if not.
#>
function Test-ParameterValid
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $ControllerLocation,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (-not (Get-Module -ListAvailable -Name Hyper-V))
    {
        $errorMessage = $script:localizedData.RoleMissingError -f 'Hyper-V'

        New-ObjectNotFoundException -Message $errorMessage
    } # if

    # Does the VM exist?
    $null = Get-VM -Name $VMName

    # Does the controller exist?
    if (-not (Get-VMScsiController -VMName $VMName -ControllerNumber $ControllerNumber) `
            -and -not (Get-VMIdeController -VMName $VMName -ControllerNumber $ControllerNumber))
    {
        # No it does not
        $errorMessage = $script:localizedData.VMControllerDoesNotExistError -f $VMName, $ControllerNumber

        New-ObjectNotFoundException -Message $errorMessage
    } # if

    # Is a Hard Drive assigned to this controller location/number?
    if (Get-VMHardDiskDrive `
            -VMName $VMName `
            -ControllerLocation $ControllerLocation `
            -ControllerNumber $ControllerNumber)
    {
        # Yes, so don't even try and touch this
        $errorMessage = $script:localizedData.ControllerConflictError -f $VMName, $ControllerNumber, $ControllerLocation

        New-ObjectNotFoundException -Message $errorMessage
    } # if

    if ($Ensure -eq 'Present')
    {
        # If the path is not blank does it exist?
        if (-not ([System.String]::IsNullOrWhiteSpace($Path)))
        {
            if (-not (Test-Path -Path $Path))
            {
                # Path does not exist
                $errorMessage = $script:localizedData.PathDoesNotExistError -f $Path

                New-ObjectNotFoundException -Message $errorMessage
            } # if
        } # if
    } # if

    return $true
} # Test-ParameterValid

Export-ModuleMember -Function *-TargetResource

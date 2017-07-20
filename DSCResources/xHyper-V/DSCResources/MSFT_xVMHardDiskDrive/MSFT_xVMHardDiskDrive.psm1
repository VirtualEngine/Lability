#region localizedData
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMHardDiskDrive.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    # fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMHardDiskDrive.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path
    )

    $hardDiskDrive = Get-VMHardDiskDrive -VMName $VMName -ErrorAction Stop |
                        Where-Object { $_.Path -eq $Path } 
    Write-Verbose "the result of the get is: $hardDiskDrive"

    if ($null -eq $hardDiskDrive)
    {
        $ensure = 'Absent'
    }
    else
    {
        $ensure = 'Present'
    }

    $returnValue = @{
        VMName = $VMName
        Path = $hardDiskDrive.Path
        ControllerType = $hardDiskDrive.ControllerType
        ControllerNumber = $hardDiskDrive.ControllerNumber
        ControllerLocation = $hardDiskDrive.ControllerLocation
        Ensure = $ensure
    }

    return $returnValue
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
    If not specified, this parameter assumes the value of the first available controller at the
    location specified in the ControllerLocation parameter.
    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the hard disk drive is to be
    set. If not specified, the first available location in the controller specified with the
    ControllerNumber parameter is used.
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet("IDE","SCSI")]
        [System.String]
        $ControllerType = "SCSI",

        [Parameter()]
        [ValidateSet(0,1,2,3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [ValidateRange(0,63)]
        [System.UInt32]
        $ControllerLocation,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $resource = Get-TargetResource -VMName $VMName -Path $Path

    # Throw exception when the ControllerNumber or the ControllerLocation are out of bounds for IDE
    if ($ControllerType -eq 'IDE' -and ($ControllerNumber -gt 1 -or $ControllerLocation -gt 1))
    {
       throw ($localizedData.NumberOrLocationOutOfBounds -f $ControllerNumber, $ControllerLocation) 
    }

    $result = $true
    foreach ($key in $resource.Keys)
    {
        Write-Verbose ($localizedData.ComparingDesiredActual -f $key,
                                                                $PSBoundParameters[$key],
                                                                $resource[$key])
        $result = $result -and ($PSBoundParameters[$key] -eq $resource[$key])
    }

    return $result    
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
    If not specified, this parameter assumes the value of the first available controller at the
    location specified in the ControllerLocation parameter.
    .PARAMETER ControllerLocation
    Specifies the number of the location on the controller at which the hard disk drive is to be
    set. If not specified, the first available location in the controller specified with the
    ControllerNumber parameter is used.
    .PARAMETER Ensure
    Specifies if the hard disk drive should exist or not. Defaults to Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet("IDE","SCSI")]
        [System.String]
        $ControllerType = "SCSI",

        [Parameter()]
        [ValidateSet(0,1,2,3)]
        [System.UInt32]
        $ControllerNumber,

        [Parameter()]
        [ValidateRange(0,63)]
        [System.UInt32]
        $ControllerLocation,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $hardDiskDrive = Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.Path -eq $Path } 

    if ($Ensure -eq "Present") 
    {
        $null = $PSBoundParameters.Remove('Ensure')

        Write-Verbose ($localizedData.CheckingIfTheDiskIsAlreadyAttachedToTheVM)
        if ($hardDiskDrive) 
        {
            Write-Verbose ($localizedData.FoundDiskButWithWrongSettings)
            $null = $PSBoundParameters.Remove('VMName')
            $null = $PSBoundParameters.Remove('Path')
            # As the operation is a move, we must use ToController... instead of Controller...
            if ($PSBoundParameters.ContainsKey('ControllerType')) 
            {
                $null = $PSBoundParameters.remove('ControllerType')
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
            return
        }
        
        Write-Verbose ($localizedData.CheckingIfThereIsAnotherDiskOnThisLocation)
        $splatGetHardDiskDrive = @{
            VMName = $VMName 
            ControllerType = $ControllerType 
            ControllerNumber = $ControllerNumber 
            ControllerLocation = $ControllerLocation
        }
        $hardDiskDrive = Get-VMHardDiskDrive @splatGetHardDiskDrive
        if ($PSBoundParameters.ContainsKey('ControllerType') -and
            $PSBoundParameters.ContainsKey('ControllerNumber') -and
            $PSBoundParameters.ContainsKey('ControllerLocation') -and
            $null -ne $hardDiskDrive)
        {
            Write-Warning ($localizedData.ThereIsAnotherDiskOnThisLocation -f $hardDiskDrive.Path)
            $null = $hardDiskDrive | Set-VMHardDiskDrive @PSBoundParameters -Path $Path 
            return
        }

        Write-Verbose ($localizedData.AddingTheDiskToTheFreeLocation)
        $null = Add-VMHardDiskDrive @PSBoundParameters 
    } 
    else # We must ensure that the disk is absent
    {
        if ($hardDiskDrive) 
        {
            Write-Verbose ($localizedData.RemovingVHDFromVM -f $Path)
            $null = $hardDiskDrive | Remove-VMHardDiskDrive 
        }
        else 
        {
            Write-Warning $localizedData.CouldNotFindDiskToRemove
        }
    }
}

Export-ModuleMember -Function *-TargetResource

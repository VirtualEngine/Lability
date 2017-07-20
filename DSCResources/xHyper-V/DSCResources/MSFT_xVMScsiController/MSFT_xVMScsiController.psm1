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

<#
    .SYNOPSIS
    Returns the current status of the VM SCSI controller.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller status is to be fetched.
    .PARAMETER ControllerNumber
    Specifies the number of the SCSI controller whose status is to be fetched. 
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
        [ValidateSet(0,1,2,3)]
        [System.Int32]
        $ControllerNumber
    )

    $controller = Get-VMScsiController -VMName $VMName -ControllerNumber $ControllerNumber
    Write-Verbose "the result of the get is: $controller"

    if ($null -eq $controller)
    {
        $ensure = 'Absent'
    }
    else
    {
        $ensure = 'Present'
    }

    $returnValue = @{
        VMName = $Controller.VMName
        ControllerNumber = $Controller.ControllerNumber
        Ensure = $ensure
    }

    return $returnValue
}

<#
    .SYNOPSIS
    Tests the state of a VM SCSI controller.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller is to be tested.
    .PARAMETER ControllerNumber
    Specifies the number of the SCSI controller to be tested. 
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $VMName,

        [Parameter(Mandatory = $true)]
        [ValidateSet(0,1,2,3)]
        [System.Int32]
        $ControllerNumber,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $null = $PSBoundParameters.Remove('Ensure')
    $resource = Get-TargetResource @PSBoundParameters

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
    Manipulates the state of a VM SCSI controller.
    .PARAMETER VMName
    Specifies the name of the virtual machine whose SCSI controller is to be manipulated.
    .PARAMETER ControllerNumber
    Specifies the number of the SCSI controller to be manipulated. 
    If not specified, the first available location is used.
    If specified, all intermediate controllers will also be created.
    .PARAMETER Ensure
    Specifies if the SCSI controller should exist or not. Defaults to Present.
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
        [ValidateSet(0,1,2,3)]
        [System.Int32]
        $ControllerNumber,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Getting the state of the VM and stop it, if it is running
    Write-Verbose $localizedData.CheckingIfVmIsRunning
    $isRunning = (Get-VM -Name $VmName).state -eq 'Running'
    if ($isRunning)
    {
        Write-Verbose $localizedData.StoppingTheVM
        Stop-VM -Name $VMName
    }    

    # Add or remove the controller(s)
    if ($Ensure -eq "Present") 
    {
        if ($PSBoundParameters.ContainsKey('ControllerNumber')) 
        {
            Write-Verbose $localizedData.ControllerNumberWasProvided
            $scsiControllerCount = (Get-VMScsiController -VMName $VMName).count
            while ($scsiControllerCount -le $ControllerNumber)
            {
                Write-Verbose ($localizedData.AddingAdditionalController -f $scsiControllerCount)
                Add-VMScsiController -VMName $VMName
                $scsiControllerCount++
            } 
        }
        else 
        {
            Write-Verbose ($localizedData.AddingAdditionalController -f $scsiControllerCount)
            Add-VMScsiController -VMName $VMName
        }
    }
    else #Absent
    {
        Write-Verbose ($localizedData.CheckingIfDrivesRemainOnController -f $ControllerNumber)
        $controller = Get-VMScsiController -VMName $VmName -ControllerNumber $ControllerNumber
        foreach ($drive in $controller.Drives)
        {
            Write-Warning ($localizedData.RemovingDriveFromController -f $drive.Path)
            Remove-VMHardDiskDrive -VMHardDiskDrive $drive
        }

        Write-Verbose ($localizedData.RemovingController -f $ControllerNumber)
        Remove-VMScsiController -VMScsiController $controller
    }

    # Restarting the VM if it was Running
    if ($isRunning) 
    {
        Write-Verbose $localizedData.RestartingVM
        Start-VM -Name $VmName
    } 
}

Export-ModuleMember -Function *-TargetResource

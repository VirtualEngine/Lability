Function Get-TargetResource
{
    [CmdletBinding()]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name
    )

    $ComponentBasedServicing = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name.Split("\") -contains "RebootPending"
    $WindowsUpdate = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name.Split("\") -contains "RebootRequired"
    $PendingFileRename = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations.Length -gt 0
    $ActiveComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
    $PendingComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
    $PendingComputerRename = $ActiveComputerName -ne $PendingComputerName
    
    $CCMSplat = @{
        NameSpace='ROOT\ccm\ClientSDK'
        Class='CCM_ClientUtilities'
        Name='DetermineIfRebootPending'
        ErrorAction='Stop'
    }

    Try {
        $CCMClientSDK = Invoke-WmiMethod @CCMSplat
    } Catch {
        Write-Warning "Unable to query CCM_ClientUtilities: $_"
    }

    $SCCMSDK = ($CCMClientSDK.ReturnValue -eq 0) -and ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)

    return @{
    Name = $Name
    ComponentBasedServicing = $ComponentBasedServicing
    WindowsUpdate = $WindowsUpdate
    PendingFileRename = $PendingFileRename
    PendingComputerRename = $PendingComputerRename
    CcmClientSDK = $SCCMSDK
    }
}

Function Set-TargetResource
{
    [CmdletBinding()]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name
    )

    $global:DSCMachineStatus = 1
}

Function Test-TargetResource
{
    [CmdletBinding()]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name
    )

    $ScriptBlocks += @{ComponentBasedServicing = {(Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name.Split("\") -contains "RebootPending"}}
    $ScriptBlocks += @{WindowsUpdate = {(Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name.Split("\") -contains "RebootRequired"}}
    $ScriptBlocks += @{PendingFileRename = {(Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations.Length -gt 0}}
    $ScriptBlocks += @{PendingComputerRename = {
            $ActiveComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
            $PendingComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
            $ActiveComputerName -ne $PendingComputerName
        }
    }
    $ScriptBlocks += @{CcmClientSDK = {
            $CCMSplat = @{
                NameSpace='ROOT\ccm\ClientSDK'
                Class='CCM_ClientUtilities'
                Name='DetermineIfRebootPending'
                ErrorAction='Stop'
            }
            Try {
                $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                ($CCMClientSDK.ReturnValue -eq 0) -and ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
            } Catch {
                Write-Warning "Unable to query CCM_ClientUtilities: $_"
            }
        }
    }
    Foreach ($Script in $ScriptBlocks.Keys) {
        If (Invoke-Command $ScriptBlocks[$Script]) {
            Write-Verbose "A pending reboot was found for $Script."
            Write-Verbose 'Setting the DSCMachineStatus global variable to 1.'
            return $false
        }
    }

    Write-Verbose 'No pending reboots found.'
    return $true
}

Export-ModuleMember -Function *-TargetResource

$regRebootLocations = $null

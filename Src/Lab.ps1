function Start-Lab {
<#
    .SYNOPSIS
        Starts all nodes in a DSC configuration document.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $nodes = @();
        $ConfigurationData.AllNodes |
            Where-Object { $_.NodeName -ne '*' } |
                ForEach-Object {
                    $nodes += ResolveLabVMProperties -NodeName $_.NodeName -ConfigurationData $ConfigurationData;
                };
        $nodes | Sort-Object { $_.BootOrder } |
            ForEach-Object {
                WriteVerbose ($localized.StartingVirtualMachine -f $_.NodeName);
                Start-VM -Name $_.NodeName;
                if ($_.BootDelay -gt 0) {
                    WriteVerbose ($localized.WaitingForVirtualMachine -f $_.BootDelay, $_.NodeName);
                    Start-Sleep -Seconds $_.BootDelay;
                }
            };
    } #end process
} #end function Start-Lab

function Stop-Lab {
<#
    .SYNOPSIS
        Stops all nodes in a DSC configuration document.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $nodes = @();
        $ConfigurationData.AllNodes |
            Where-Object { $_.NodeName -ne '*' } |
                ForEach-Object {
                    $nodes += ResolveLabVMProperties -NodeName $_.NodeName -ConfigurationData $ConfigurationData;
                };
        $nodes | Sort-Object { $_.BootOrder } -Descending |
            ForEach-Object {
                WriteVerbose ($localized.StoppingVirtualMachine -f $_.NodeName);
                Stop-VM -Name $_.NodeName;
                if ($_.BootDelay -gt 0) {
                    WriteVerbose ($localized.WaitingForVirtualMachine -f $_.BootDelay, $_.NodeName);
                    Start-Sleep -Seconds $_.BootDelay;
                }
            };
    } #end process
} #end function Stop-Lab

function Reset-Lab {
<#
    .SYNOPSIS
        Reverts a lab back to it's intial configuration.
    .NOTES
        This uses the baseline snapshot. If they don't exist, the lab can also be reconfigured with Start-LabConfiguration -Force.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        ## Revert to Base/Lab snapshots...
        $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
        Restore-Lab -ConfigurationData $ConfigurationData -SnapshotName $snapshotName -Force;
    } #end process
} #end function Reset-Lab

function Checkpoint-Lab {
<#
    .SYNOPSIS
        Snapshots a lab in it's current configuration with the supplied name/description.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Snapshot name
        [Parameter(Mandatory)] [System.String] [Alias('Name')] $SnapshotName,
        ## Force snapshots if virtual machines are on
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
         $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' } | ForEach-Object { $_.NodeName };
         $runningNodes = Get-VM -Name $nodes | Where-Object { $_.State -ne 'Off' }
         if ($runningNodes -and $Force) {
            NewLabVMSnapshot -Name $nodes -SnapshotName $SnapshotName;
         }
         elseif ($runningNodes) {
            foreach ($runningNode in $runningNodes) {
                Write-Error ($localized.CannotSnapshotNodeError -f $runningNode.Name);
            }
         }
         else {
            NewLabVMSnapshot -Name $nodes -SnapshotName $SnapshotName;
         }
    } #end process
} #end function Checkpoint-Lab

function Restore-Lab {
<#
    .SYNOPSIS
        Reverts a lab to a previous snapshot name/description.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [Parameter(Mandatory, ValueFromPipeline)] [System.Object] $ConfigurationData,
        ## Snapshot name
        [Parameter(Mandatory)] [System.String] [Alias('Name')] $SnapshotName,
        ## Force snapshots if virtual machines are on
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        $ConfigurationData = ConvertToConfigurationData -ConfigurationData $ConfigurationData;
    }
    process {
        $nodes = @();
        $ConfigurationData.AllNodes |
            Where-Object { $_.NodeName -ne '*' } |
                ForEach-Object {
                    $nodes += ResolveLabVMProperties -NodeName $_.NodeName -ConfigurationData $ConfigurationData;
                };
        $runningNodes = $nodes | ForEach-Object {
            Get-VM -Name $_.NodeName } |
                Where-Object { $_.State -ne 'Off' }
            
        if ($runningNodes -and $Force) {
            $nodes | Sort-Object { $_.BootOrder } |
                ForEach-Object {
                    WriteVerbose ($localized.RestoringVirtualMachineSnapshot -f $_.NodeName,  $SnapshotName);
                    GetLabVMSnapshot -Name $_.NodeName -SnapshotName $SnapshotName | Restore-VMSnapshot;
                }
        }
        elseif ($runningNodes) {
            foreach ($runningNode in $runningNodes) {
                Write-Error ($localized.CannotSnapshotNodeError -f $runningNode.NodeName);
            }
        }
        else {
            $nodes | Sort-Object { $_.BootOrder } |
                ForEach-Object {
                    WriteVerbose ($localized.RestoringVirtualMachineSnapshot -f $_.NodeName,  $SnapshotName);
                    GetLabVMSnapshot -Name $_.NodeName -SnapshotName $SnapshotName | Restore-VMSnapshot -Confirm:$false;
                }
        }
    } #end process
} #end function Restore-Lab

function Start-Lab {
<#
     .SYNOPSIS
        Starts all VMs in a lab in a predefined order.
    .DESCRIPTION
        The Start-Lab cmdlet starts all nodes defined in a PowerShell DSC configuration document, in a preconfigured
        order.
        
        Unlike the standard Start-VM cmdlet, the Start-Lab cmdlet will read the specified PowerShell DSC configuration
        document and infer the required start up order.
        
        The PowerShell DSC configuration document can define the start/stop order of the virtual machines and the boot
        delay between each VM power operation. This is defined with the BootOrder and BootDelay properties. The lower
        the virtual machine's BootOrder index, the earlier it is started (in relation to the other VMs).
        
        For example, a VM with a BootOrder index of 10 will be started before a VM with a BootOrder index of 11. All
        virtual machines receive a BootOrder value of 99 unless specified otherwise.

        The delay between each power operation is defined with the BootDelay property. This value is specified in
        seconds and is enforced between starting or stopping a virtual machine.
        
        For example, a VM with a BootDelay of 30 will enforce a 30 second delay after being powered on or after the
        power off command is issued. All VMs receive a BootDelay value of 0 (no delay) unless specified otherwise.       
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .LINK
        about_ConfigurationData
        Stop-Lab
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
        Stops all VMs in a lab in a predefined order.
    .DESCRIPTION
        The Stop-Lab cmdlet stops all nodes defined in a PowerShell DSC configuration document, in a preconfigured
        order.
        
        Unlike the standard Stop-VM cmdlet, the Stop-Lab cmdlet will read the specified PowerShell DSC configuration
        document and infer the required shutdown order.
        
        The PowerShell DSC configuration document can define the start/stop order of the virtual machines and the boot
        delay between each VM power operation. This is defined with the BootOrder and BootDelay properties. The higher
        the virtual machine's BootOrder index, the earlier it is stopped (in relation to the other VMs).
        
        For example, a VM with a BootOrder index of 11 will be stopped before a VM with a BootOrder index of 10. All
        virtual machines receive a BootOrder value of 99 unless specified otherwise.

        The delay between each power operation is defined with the BootDelay property. This value is specified in
        seconds and is enforced between starting or stopping a virtual machine.
        
        For example, a VM with a BootDelay of 30 will enforce a 30 second delay after being powered on or after the
        power off command is issued. All VMs receive a BootDelay value of 0 (no delay) unless specified otherwise.       
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .LINK
        about_ConfigurationData
        Start-Lab
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
        Reverts all VMs in a lab back to their initial configuration.
    .DESCRIPTION
        The Reset-Lab cmdlet will reset all the nodes defined in a PowerShell DSC configuration document, back to their
        initial state. If virtual machines are powered on, they will automatically be powered off when restoring the
        snapshot.

        When virtual machines are created - before they are powered on - a baseline snapshot is created. This snapshot
        is taken before the Sysprep process has been run and/or any PowerShell DSC configuration has been applied.
        
        WARNING: You will lose all changes to all virtual machines that have not been committed via another snapshot.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .LINK
        Checkpoint-Lab
    .NOTES
        This cmdlet uses the baseline snapshot snapshot created by the Start-LabConfiguration cmdlet. If the baseline
        was not created or the baseline snapshot does not exist, the lab VMs can be recreated with the
        Start-LabConfiguration -Force.
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
        Snapshots all lab VMs in their current configuration.
    .DESCRIPTION
        The Checkpoint-Lab creates a VM checkpoint of all the nodes defined in a PowerShell DSC configuration document.
        When creating the snapshots, they will be created using the snapshot name specified.

        All virtual machines should be powered off when the snapshot is taken to ensure that the machine is in a
        consistent state. If VMs are powered on, an error will be generated. You can override this behaviour by
        specifying the -Force parameter.

        WARNING: If the -Force parameter is used, the virtual machine snapshot(s) may be in an inconsistent state.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .PARAMETER SnapshotName
        Specifies the virtual machine snapshot name that applied to each VM in the PowerShell DSC configuration
        document. This name is used to restore a lab configuration. It can contain spaces, but is not recommended.
    .PARAMETER Force
        Forces virtual machine snapshots to be taken - even if there are any running virtual machines.
    .LINK
        Restore-Lab
        Reset-Lab
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
        Restores all lab VMs to a previous configuration.
    .DESCRIPTION
        The Restore-Lab reverts all the nodes defined in a PowerShell DSC configuration document, back to a
        previously captured configuration.

        When creating the snapshots, they are created using a snapshot name. To restore a lab to a previous
        configuration, you must supply the same snapshot name.

        All virtual machines should be powered off when the snapshots are restored. If VMs are powered on,
        an error will be generated. You can override this behaviour by specifying the -Force parameter.

        WARNING: If the -Force parameter is used, running virtual machines will be powered off automatically.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .PARAMETER SnapshotName
        Specifies the virtual machine snapshot name to be restored. You must use the same snapshot name used when
        creating the snapshot with the Checkpoint-Lab cmdlet.
    .PARAMETER Force
        Forces virtual machine snapshots to be restored - even if there are any running virtual machines.
    .LINK
        Checkpoint-Lab
        Reset-Lab
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

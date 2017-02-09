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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Snapshot name
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String] $SnapshotName,

        ## Force snapshots if virtual machines are on
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' } | ForEach-Object {
             Resolve-NodePropertyValue -NodeName $_.NodeName -ConfigurationData $ConfigurationData;
        };

        $runningNodes = Get-VM -Name $nodes.NodeDisplayName | Where-Object { $_.State -ne 'Off' }

        if ($runningNodes -and $Force) {

            NewLabVMSnapshot -Name $nodes.NodeDisplayName -SnapshotName $SnapshotName;
        }
        elseif ($runningNodes) {

            foreach ($runningNode in $runningNodes) {

                Write-Error -Message ($localized.CannotSnapshotNodeError -f $runningNode.Name);
            }
        }
        else {

            $nodesDisplayString = [System.String]::Join(', ', $nodes.NodeDisplayName);
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Checkpoint-Lab', $node.Name;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.CreatingVirtualMachineSnapshot -f $nodesDisplayString, $SnapshotName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                NewLabVMSnapshot -Name $nodes.NodeDisplayName -SnapshotName $SnapshotName;
            }
        }

    } #end process
} #end function Checkpoint-Lab

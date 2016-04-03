function RemoveLabVMSnapshot {
<#
    .SYNOPSIS
        Removes a VM snapshot.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $SnapshotName = '*'
    )
    process {
       <## TODO: Add the ability to force/wait for the snapshots to be removed. When removing snapshots it take a minute
                 or two before the files are actually removed. This causes issues when performing a lab reset #>
        foreach ($vmName in $Name) {
        
            # Sort by descending CreationTime to ensure we will not have to commit changes from one snapshot to another
            Get-VMSnapshot -VMName $vmName -ErrorAction SilentlyContinue |
                Where-Object Name -like $SnapshotName |
                    Sort-Object -Property CreationTime -Descending |
                        ForEach-Object {
                            WriteVerbose -Message ($localized.RemovingSnapshot -f $vmName, $_.Name);
                            Remove-VMSnapshot -VMName $_.VMName -Name $_.Name -Confirm:$false;
                        }

        } #end foreach VM
    } #end process
} #end function RemoveVMSnapshot

function NewLabVMSnapshot {
<#
    .SYNOPSIS
        Creates a snapshot of all virtual machines with the specified snapshot name.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $SnapshotName
    )
    process {
        foreach ($vmName in $Name) {
            WriteVerbose -Message ($localized.SnapshottingVirtualMachine -f $vmName, $SnapshotName);
            Checkpoint-VM -VMName $vmName -SnapshotName $SnapshotName;
        } #end foreach VM
    } #end process
} #end function RemoveVMSnapshot

function GetLabVMSnapshot {
<#
    .SYNOPSIS
        Gets snapshots of all virtual machines with the specified snapshot name.
#>
    [CmdletBinding()]
    param (
        ## VM/node name.
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,
        
        ## Snapshot name to restore.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $SnapshotName
    )
    process {
        foreach ($vmName in $Name) {
            $snapshot = Get-VMSnapshot -VMName $vmName -Name $SnapshotName -ErrorAction SilentlyContinue;
            if (-not $snapshot) {
                WriteWarning -Message ($localized.SnapshotMissingWarning -f $SnapshotName, $vmName);
            }
            else {
                Write-Output -InputObject $snapshot;
            }
        } #end foreach VM
    } #end process
} #end function GetLabVMSnapshot

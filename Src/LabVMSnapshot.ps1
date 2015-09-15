function RemoveLabVMSnapshot {
<#
    .SYNOPSIS
        Removes a VM snapshot.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $Name,
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $SnapshotName = '*'
    )
    process {
        foreach ($vmName in $Name) {
            Get-VMSnapshot -VMName $Name -ErrorAction SilentlyContinue | Where Name -like $SnapshotName | ForEach-Object {
                WriteVerbose ($localized.RemovingSnapshot -f $vmName, $_.Name);
                $_ | Remove-VMSnapshot;
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $SnapshotName
    )
    process {
        foreach ($vmName in $Name) {
            WriteVerbose ($localized.SnapshottingVirtualMachine -f $vmName, $SnapshotName);
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
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String[]] $Name,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $SnapshotName
    )
    process {
        foreach ($vmName in $Name) {
            $snapshot = Get-VMSnapshot -VMName $vmName -Name $SnapshotName -ErrorAction SilentlyContinue;
            if (-not $snapshot) {
                WriteWarning ($localized.SnapshotMissingWarning -f $SnapshotName, $vmName);
            }
            else {
                Write-Output $snapshot;
            }
        } #end foreach VM
    } #end process
} #end function GetLabVMSnapshot

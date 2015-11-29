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
       <## TODO: Add the ability to force/wait for the snapshots to be removed. When removing snapshots it take a minute
                 or two before the files are actually removed. This causes issues when performing a lab reset #>
        foreach ($vmName in $Name) {
            Get-VMSnapshot -VMName $vmName -ErrorAction SilentlyContinue | Where Name -like $SnapshotName | ForEach-Object {
                WriteVerbose ($localized.RemovingSnapshot -f $vmName, $_.Name);
                Remove-VMSnapshot -VMName $_.VMName -Name $_.Name;
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

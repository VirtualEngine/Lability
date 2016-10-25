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

}


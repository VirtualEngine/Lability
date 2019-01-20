function Get-LabVMSnapshot {
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

            $snapshot = Hyper-V\Get-VMSnapshot -VMName $vmName -Name $SnapshotName -ErrorAction SilentlyContinue;
            if (-not $snapshot) {

                Write-Warning -Message ($localized.SnapshotMissingWarning -f $SnapshotName, $vmName);
            }
            else {

                Write-Output -InputObject $snapshot;
            }
        } #end foreach VM

    } #end process
} #end function

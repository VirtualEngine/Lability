function Remove-LabVMSnapshot {
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
                            Write-Verbose -Message ($localized.RemovingSnapshot -f $vmName, $_.Name);
                            Remove-VMSnapshot -VMName $_.VMName -Name $_.Name -Confirm:$false;
                        }

        } #end foreach VM

    } #end process
} #end function

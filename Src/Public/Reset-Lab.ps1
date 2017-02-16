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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        ## Revert to Base/Lab snapshots...
        $snapshotName = $localized.BaselineSnapshotName -f $labDefaults.ModuleName;
        Restore-Lab -ConfigurationData $ConfigurationData -SnapshotName $snapshotName -Force;

    } #end process
} #end function Reset-Lab

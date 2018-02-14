function Remove-LabConfiguration {
<#
    .SYNOPSIS
        Removes all VMs and associated snapshots of all nodes defined in a PowerShell DSC configuration document.
    .DESCRIPTION
        The Remove-LabConfiguration removes all virtual machines that have a corresponding NodeName defined in the
        AllNode array of the PowerShell DSC configuration document.

        WARNING: ALL EXISTING VIRTUAL MACHINE DATA WILL BE LOST WHEN VIRTUAL MACHINES ARE REMOVED.

        By default, associated virtual machine switches are not removed as they may be used by other virtual
        machines or lab configurations. If you wish to remove any virtual switche defined in the PowerShell DSC
        configuration document, specify the -RemoveSwitch parameter.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to remove existing virtual machines. One virtual machine is removed per node
        defined in the AllNodes array.
    .PARAMETER RemoveSwitch
        Specifies that any connected virtual switch should also be removed when the virtual machine is removed.
    .LINK
        about_ConfigurationData
        Start-LabConfiguration
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Include removal of virtual switch(es). By default virtual switches are not removed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $RemoveSwitch
    )
    process {

        Write-Verbose -Message $localized.StartedLabConfiguration;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };
        $currentNodeCount = 0;
        foreach ($node in $nodes) {

            $currentNodeCount++;
            $nodeProperties = Resolve-NodePropertyValue -NodeName $node.NodeName -ConfigurationData $ConfigurationData;
            [System.Int16] $percentComplete = (($currentNodeCount / $nodes.Count) * 100) - 1;
            $activity = $localized.ConfiguringNode -f $nodeProperties.NodeDisplayName;
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

            ##TODO: Should this not ensure that VMs are powered off
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Remove-Lab', $nodeProperties.NodeDisplayName;
            $verboseProcessMessage = Get-FormattedMessage -Message ($localized.RemovingVM -f $nodeProperties.NodeDisplayName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                Remove-LabVirtualMachine -Name $node.NodeName -ConfigurationData $ConfigurationData -RemoveSwitch:$RemoveSwitch -Confirm:$false;
            }

        } #end foreach node

        Write-Progress -Id 42 -Activity $activity -Completed;
        Write-Verbose -Message $localized.FinishedLabConfiguration;

    } #end process
} #end function Remove-LabConfiguration

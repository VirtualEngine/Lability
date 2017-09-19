function Test-LabConfiguration {
<#
    .SYNOPSIS
        Tests the configuration of all VMs in a lab.
    .DESCRIPTION
        The Test-LabConfiguration determines whether all nodes defined in a PowerShell DSC configuration document
        are configured correctly and returns the results.

        WANRING: Only the virtual machine configuration is checked, not in the internal VM configuration. For example,
        the virtual machine's memory configuraiton, virtual switch configuration and processor count are tested. The
        VM's operating system configuration is not checked.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. Each node defined in the AllNodes array is
        tested.
    .LINK
        about_ConfigurationData
        Start-LabConfiguration
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        Write-Verbose -Message $localized.StartedLabConfigurationTest;
        $currentNodeCount = 0;
        $nodes = $ConfigurationData.AllNodes | Where-Object { $_.NodeName -ne '*' };
        foreach ($node in $nodes) {

            $currentNodeCount++;
            $nodeProperties = Resolve-NodePropertyValue -NodeName $node.NodeName -ConfigurationData $ConfigurationData;
            [System.Int16] $percentComplete = (($currentNodeCount / $nodes.Count) * 100) - 1;
            $activity = $localized.ConfiguringNode -f $nodeProperties.NodeDisplayName;
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
            $nodeResult = [PSCustomObject] @{
                Name = $nodeProperties.NodeName;
                IsConfigured = Test-LabVM -Name $node.NodeName -ConfigurationData $ConfigurationData;
                DisplayName = $nodeProperties.NodeDisplayName;
            }
            Write-Output -InputObject $nodeResult;
        }

        Write-Verbose -Message $localized.FinishedLabConfigurationTest;

    } #end process
} #end function Test-LabConfiguration

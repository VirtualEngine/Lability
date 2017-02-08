function Start-Lab {
<#
    .SYNOPSIS
        Starts all VMs in a lab in a predefined order.
    .DESCRIPTION
        The Start-Lab cmdlet starts all nodes defined in a PowerShell DSC configuration document, in a preconfigured
        order.

        Unlike the standard Start-VM cmdlet, the Start-Lab cmdlet will read the specified PowerShell DSC configuration
        document and infer the required start up order.

        The PowerShell DSC configuration document can define the start/stop order of the virtual machines and the boot
        delay between each VM power operation. This is defined with the BootOrder and BootDelay properties. The lower
        the virtual machine's BootOrder index, the earlier it is started (in relation to the other VMs).

        For example, a VM with a BootOrder index of 10 will be started before a VM with a BootOrder index of 11. All
        virtual machines receive a BootOrder value of 99 unless specified otherwise.

        The delay between each power operation is defined with the BootDelay property. This value is specified in
        seconds and is enforced between starting or stopping a virtual machine.

        For example, a VM with a BootDelay of 30 will enforce a 30 second delay after being powered on or after the
        power off command is issued. All VMs receive a BootDelay value of 0 (no delay) unless specified otherwise.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document.
    .LINK
        about_ConfigurationData
        Stop-Lab
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','nodes')]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $nodes = @();
        $ConfigurationData.AllNodes |
            Where-Object { $_.NodeName -ne '*' } |
                ForEach-Object {
                    $nodes += [PSCustomObject] (ResolveLabVMProperties -NodeName $_.NodeName -ConfigurationData $ConfigurationData);
                };

        $currentGroupCount = 0;
        $bootGroups = $nodes | Sort-Object -Property BootOrder | Group-Object -Property BootOrder;
        $bootGroups | ForEach-Object {

            $nodeDisplayNames = $_.Group.NodeDisplayName;
            $nodeDisplayNamesString = $nodeDisplayNames -join ', ';
            $currentGroupCount++;
            [System.Int32] $percentComplete = ($currentGroupCount / $bootGroups.Count) * 100;
            $activity = $localized.ConfiguringNode -f $nodeDisplayNamesString;
            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
            WriteVerbose ($localized.StartingVirtualMachine -f $nodeDisplayNamesString);
            Start-VM -Name $nodeDisplayNames;

            $maxGroupBootDelay = $_.Group.BootDelay | Sort-Object -Descending | Select-Object -First 1;
            if (($maxGroupBootDelay -gt 0) -and ($currentGroupCount -lt $bootGroups.Count)) {

                WriteVerbose ($localized.WaitingForVirtualMachine -f $maxGroupBootDelay, $nodeDisplayNamesString);
                for ($i = 1; $i -le $maxGroupBootDelay; $i++) {

                    [System.Int32] $waitPercentComplete = ($i / $maxGroupBootDelay) * 100;
                    $waitActivity = $localized.WaitingForVirtualMachine -f $maxGroupBootDelay, $nodeDisplayNamesString;
                    Write-Progress -ParentId 42 -Activity $waitActivity -PercentComplete $waitPercentComplete;
                    Start-Sleep -Seconds 1;
                }

                Write-Progress -Activity $waitActivity -Completed;

            } #end if boot delay
        } #end foreach boot group

        Write-Progress -Id 42 -Activity $activity -Completed;

    } #end process
} #end function Start-Lab

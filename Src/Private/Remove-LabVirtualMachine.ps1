function Remove-LabVirtualMachine {
    <#
        .SYNOPSIS
            Deletes a lab virtual machine.
    #>
        [CmdletBinding(SupportsShouldProcess)]
        param (
            ## Specifies the lab virtual machine/node name.
            [Parameter(Mandatory, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()]
            [System.String] $Name,

            ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
            [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [System.Collections.Hashtable]
            [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
            $ConfigurationData,

            ## Include removal of virtual switch(es). By default virtual switches are not removed.
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.Management.Automation.SwitchParameter] $RemoveSwitch
        )
        process {

            if (-not (Test-LabNode -Name $Name -ConfigurationData $ConfigurationData)) {

                throw ($localized.CannotLocateNodeError -f $Name);
            }
            $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData;
            $nodeDisplayName = $node.NodeDisplayName;

            # Revert to oldest snapshot prior to VM removal to speed things up
            Get-VMSnapshot -VMName $nodeDisplayName -ErrorAction SilentlyContinue |
                Sort-Object -Property CreationTime |
                    Select-Object -First 1 |
                        Restore-VMSnapshot -Confirm:$false;

            Remove-LabVMSnapshot -Name $nodeDisplayName;

            $environmentSwitchNames = @();
            foreach ($switchName in $node.SwitchName) {

                $environmentSwitchNames += Resolve-LabEnvironmentName -Name $switchName -ConfigurationData $ConfigurationData;
            }

            Write-Verbose -Message ($localized.RemovingNodeConfiguration -f 'VM', $nodeDisplayName);
            $clearLabVirtualMachineParams = @{
                Name = $nodeDisplayName;
                SwitchName = $environmentSwitchNames;
                Media = $node.Media;
                StartupMemory = $node.StartupMemory;
                MinimumMemory = $node.MinimumMemory;
                MaximumMemory = $node.MaximumMemory;
                MACAddress = $node.MACAddress;
                ProcessorCount = $node.ProcessorCount;
                ConfigurationData = $ConfigurationData;
            }
            Clear-LabVirtualMachine @clearLabVirtualMachineParams;

            ## Remove the OS disk
            Write-Verbose -Message ($localized.RemovingNodeConfiguration -f 'VHD/X', "$($nodeDisplayName).vhd/vhdx");
            $removeLabVMDiskParams = @{
                Name = $nodeDisplayName;
                NodeName = $Name;
                Media = $node.Media;
                ConfigurationData = $ConfigurationData;
            }
            Remove-LabVMDisk @removeLabVMDiskParams -ErrorAction Stop;

            if ($RemoveSwitch) {

                foreach ($switchName in $node.SwitchName) {

                    $environmentSwitchName = Resolve-LabEnvironmentName -Name $switchName -ConfigurationData $ConfigurationData;
                    Write-Verbose -Message ($localized.RemovingNodeConfiguration -f 'Virtual Switch', $environmentSwitchName);
                    Remove-LabSwitch -Name $switchName -ConfigurationData $ConfigurationData;
                }
            }

        } #end process
    } #end function

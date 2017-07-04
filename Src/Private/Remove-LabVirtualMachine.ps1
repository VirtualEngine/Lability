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

        $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
        if (-not $node.NodeName) {
            throw ($localized.CannotLocateNodeError -f $Name);
        }
        $Name = $node.NodeDisplayName;

        # Revert to oldest snapshot prior to VM removal to speed things up
        Get-VMSnapshot -VMName $Name -ErrorAction SilentlyContinue |
            Sort-Object -Property CreationTime |
                Select-Object -First 1 |
                    Restore-VMSnapshot -Confirm:$false;

        RemoveLabVMSnapshot -Name $Name;

        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VM', $Name);
        $clearLabVirtualMachineParams = @{
            Name = $Name;
            SwitchName = $node.SwitchName;
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
        WriteVerbose ($localized.RemovingNodeConfiguration -f 'VHD/X', "$Name.vhd/vhdx");
        $removeLabVMDiskParams = @{
            Name = $node.NodeDisplayName;
            NodeName = $Name;
            Media = $node.Media;
            ConfigurationData = $ConfigurationData;
        }
        Remove-LabVMDisk @removeLabVMDiskParams -ErrorAction Stop;

        if ($RemoveSwitch) {

            WriteVerbose ($localized.RemovingNodeConfiguration -f 'Virtual Switch', $node.SwitchName);
            Remove-LabSwitch -Name $node.SwitchName -ConfigurationData $ConfigurationData;
        }

    } #end process
} #end function

function Remove-LabVirtualMachineHardDiskDrive {
<#
    .SYNOPSIS
        Removes a virtual machine's additional hard disk drive(s).
    .DESCRIPTION
        Removes one or more additional hard disks. No need to detach the disks as the VM is deleted.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $NodeName,

        ## Collection of additional hard disk drive configurations
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable[]]
        $HardDiskDrive
    )
    process {

        $vmHardDiskPath = (Get-ConfigurationData -Configuration Host).DifferencingVhdPath;

        for ($i = 0; $i -lt $HardDiskDrive.Count; $i++) {

            $diskDrive = $HardDiskDrive[$i];
            $controllerLocation = $i + 1;

            if ($diskDrive.ContainsKey('VhdPath')) {

                ## Do not remove VHD/Xs created externally!
            }
            else {

                ## Remove the VHD file
                $vhdName = '{0}-{1}' -f $NodeName, $controllerLocation;
                $vhdParams = @{
                    Name = $vhdName;
                    Path = $vmHardDiskPath;
                    MaximumSizeBytes = $diskDrive.MaximumSizeBytes;
                    Generation = $diskDrive.Type;
                    Ensure = 'Absent';
                }

                $vhdFilename = '{0}.{1}' -f $vhdName, $diskDrive.Type.ToLower();
                $vhdPath = Join-Path -Path $vmHardDiskPath -ChildPath $vhdFilename;
                WriteVerbose -Message ($localized.RemovingVhdFile -f $vhdPath);
                ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVhd -Prefix Vhd;
                InvokeDscResource -ResourceName Vhd -Parameters $vhdParams;

            }

        } #end for

    } #end process
} #end function

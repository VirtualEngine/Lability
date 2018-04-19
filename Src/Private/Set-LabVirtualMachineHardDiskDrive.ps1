function Set-LabVirtualMachineHardDiskDrive {
<#
    .SYNOPSIS
        Sets a virtual machine's additional hard disk drive(s).
    .DESCRIPTION
        Adds one or more additional hard disks to a VM.
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
        $HardDiskDrive,

        ## Virtual machine generation
        [Parameter()]
        [System.Int32] $VMGeneration
    )
    process {

        $vmHardDiskPath = (Get-ConfigurationData -Configuration Host).DifferencingVhdPath;

        for ($i = 0; $i -lt $HardDiskDrive.Count; $i++) {

            $diskDrive = $HardDiskDrive[$i];
            $controllerLocation = $i + 1;

            Assert-VirtualMachineHardDiskDriveParameter @diskDrive -VMGeneration $VMGeneration;

            if ($diskDrive.ContainsKey('VhdPath')) {

                $vhdPath = $diskDrive.VhdPath;
            }
            else {

                ## Create the VHD file
                $vhdName = '{0}-{1}' -f $NodeName, $controllerLocation;
                $vhdParams = @{
                    Name = $vhdName;
                    Path = $vmHardDiskPath;
                    MaximumSizeBytes = $diskDrive.MaximumSizeBytes;
                    Generation = $diskDrive.Generation;
                    Ensure = 'Present';
                }

                $vhdFilename = '{0}.{1}' -f $vhdName, $diskDrive.Generation.ToLower();
                $vhdPath = Join-Path -Path $vmHardDiskPath -ChildPath $vhdFilename;
                Write-Verbose -Message ($localized.CreatingAdditionalVhdFile -f $vhdPath);
                Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVhd -Prefix Vhd;
                Invoke-LabDscResource -ResourceName Vhd -Parameters $vhdParams;
            }

            ## Now add the VHD
            Write-Verbose -Message ($localized.AddingAdditionalVhdFile -f $vhdPath, "0:$controllerLocation");
            $vmHardDiskDriveParams = @{
                VMName = $NodeName;
                ControllerLocation = $controllerLocation;
                Path = $VhdPath;
                Ensure = 'Present';
            }
            Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHardDiskDrive -Prefix HardDiskDrive;
            Invoke-LabDscResource -ResourceName HardDiskDrive -Parameters $vmHardDiskDriveParams;

        } #end for

    } #end process
} #end function

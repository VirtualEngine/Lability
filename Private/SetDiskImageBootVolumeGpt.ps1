function SetDiskImageBootVolumeGpt {

<#
    .SYNOPSIS
        Configure/repair MBR boot volume
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd # Microsoft.Vhd.PowerShell.VirtualHardDisk
    )
    process {

        $bcdBootExe = 'bcdboot.exe';
        $imageName = [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);

        $systemPartitionDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType 'System';
        $osPartitionDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType 'Basic';
        WriteVerbose ($localized.RepairingBootVolume -f $osPartitionDriveLetter);
        $bcdBootArgs = @(
            ('{0}:\Windows' -f $osPartitionDriveLetter),   # Path to source Windows boot files
            ('/s {0}:\' -f $systemPartitionDriveLetter),   # Specifies the volume letter of the drive to create the \BOOT folder on.
            '/v'                                           # Enabled verbose logging.
            '/f UEFI'                                      # Specifies the firmware type of the target system partition
        )
        InvokeExecutable -Path $bcdBootExe -Arguments $bcdBootArgs -LogName ('{0}-BootEdit.log' -f $imageName);
        ## Clean up and remove drive access path
        Remove-PSDrive -Name $osPartitionDriveLetter -PSProvider FileSystem -ErrorAction Ignore;
        [ref] $null = Get-PSDrive;

    } #end process

}


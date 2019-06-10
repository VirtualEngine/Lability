function Set-DiskImageBootVolumeMbr {
<#
    .SYNOPSIS
        Configure/repair MBR boot volume
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [System.Object] $Vhd # Microsoft.Vhd.PowerShell.VirtualHardDisk
    )
    process {

        $bcdBootExe = 'bcdboot.exe';
        $bcdEditExe = 'bcdedit.exe';
        $imageName = [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);

        $osPartitionDriveLetter = Get-DiskImageDriveLetter -DiskImage $Vhd -PartitionType 'IFS';
        Write-Verbose -Message ($localized.RepairingBootVolume -f $osPartitionDriveLetter);
        $bcdBootArgs = @(
            ('{0}:\Windows' -f $osPartitionDriveLetter), # Path to source Windows boot files
            ('/s {0}:\' -f $osPartitionDriveLetter),     # Volume to create the \BOOT folder on.
            '/v'                                         # Enable verbose logging.
            '/f BIOS'                                    # Firmware type of the target system partition
        )
        Invoke-Executable -Path $bcdBootExe -Arguments $bcdBootArgs -LogName ('{0}-BootEdit.log' -f $imageName);

        $bootmgrDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {bootmgr} device locate'
        );
        Invoke-Executable -Path $bcdEditExe -Arguments $bootmgrDeviceArgs -LogName ('{0}-BootmgrDevice.log' -f $imageName);

        $defaultDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {default} device locate'
        );
        Invoke-Executable -Path $bcdEditExe -Arguments $defaultDeviceArgs -LogName ('{0}-DefaultDevice.log' -f $imageName);

        $defaultOsDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {default} osdevice locate'
        );
        Invoke-Executable -Path $bcdEditExe -Arguments $defaultOsDeviceArgs -LogName ('{0}-DefaultOsDevice.log' -f $imageName);

    } #end process
} #end function

function GetDiskImageDriveLetter {
<#
    .SYNOPSIS
        Return a disk image's associated/mounted drive letter.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $DiskImage,

        [Parameter(Mandatory)]
        [ValidateSet('Basic','System','IFS')]
        [System.String] $PartitionType
    )
    process {

        # Microsoft.Vhd.PowerShell.VirtualHardDisk
        $driveLetter = Get-Partition -DiskNumber $DiskImage.DiskNumber |
            Where-Object Type -eq $PartitionType |
                Where-Object DriveLetter |
                    Select-Object -Last 1 -ExpandProperty DriveLetter;

        if (-not $driveLetter) {

            throw ($localized.CannotLocateDiskImageLetter -f $DiskImage.Path);
        }
        return $driveLetter;
    }
} #end function GetDiskImageDriveLetter


function NewDiskImageMbr {
<#
    .SYNOPSIS
        Create a new MBR-formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd # Microsoft.Vhd.PowerShell.VirtualHardDisk
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx

        Stop-ShellHWDetectionService;

        WriteVerbose ($localized.CreatingDiskPartition -f 'Windows');
        $osPartition = New-Partition -DiskNumber $Vhd.DiskNumber -UseMaximumSize -MbrType IFS -IsActive |
            Add-PartitionAccessPath -AssignDriveLetter -PassThru |
                Get-Partition;
        WriteVerbose ($localized.FormattingDiskPartition -f 'Windows');
        [ref] $null = Format-Volume -Partition $osPartition -FileSystem NTFS -Force -Confirm:$false;

        Start-ShellHWDetectionService;

    } #end proces
} #end function NewDiskImageMbr


function NewDiskPartFat32Partition {
<#
    .SYNOPSIS
        Uses DISKPART.EXE to create a new Fat32 system partition. This permits mocking of DISKPART calls.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Int32] $DiskNumber,

        [Parameter(Mandatory)]
        [System.Int32] $PartitionNumber
    )
    process {
        @"
select disk $DiskNumber
select partition $PartitionNumber
format fs=fat32 label="System"
"@ | & "$env:SystemRoot\System32\DiskPart.exe" | Out-Null;
    }
}


function NewDiskImageGpt {
<#
    .SYNOPSIS
        Create a new GPT-formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd # Microsoft.Vhd.PowerShell.VirtualHardDisk
    )
    process {

        ## Temporarily disable Windows Explorer popup disk initialization and format notifications
        ## http://blogs.technet.com/b/heyscriptingguy/archive/2013/05/29/use-powershell-to-initialize-raw-disks-and-partition-and-format-volumes.aspx
        Stop-ShellHWDetectionService;

        WriteVerbose ($localized.CreatingDiskPartition -f 'EFI');
        $efiPartition = New-Partition -DiskNumber $Vhd.DiskNumber -Size 250MB -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -AssignDriveLetter;
        WriteVerbose ($localized.FormattingDiskPartition -f 'EFI');
        NewDiskPartFat32Partition -DiskNumber $Vhd.DiskNumber -PartitionNumber $efiPartition.PartitionNumber;

        WriteVerbose ($localized.CreatingDiskPartition -f 'MSR');
        [ref] $null = New-Partition -DiskNumber $Vhd.DiskNumber -Size 128MB -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}';

        WriteVerbose ($localized.CreatingDiskPartition -f 'Windows');
        $osPartition = New-Partition -DiskNumber $Vhd.DiskNumber -UseMaximumSize -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -AssignDriveLetter;
        WriteVerbose ($localized.FormattingDiskPartition -f 'Windows');
        [ref] $null = Format-Volume -Partition $osPartition -FileSystem NTFS -Force -Confirm:$false;

        Start-ShellHWDetectionService;

    } #end process
} #end function NewDiskImageGpt


function NewDiskImage {
<#
    .SYNOPSIS
        Create a new formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## VHD/x file path
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Disk image size in bytes
        [Parameter()]
        [System.UInt64] $Size = 127GB,

        ## Overwrite/recreate existing disk image
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Do not dismount the VHD/x and return a reference
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Passthru
    )
    begin {

        if ((Test-Path -Path $Path -PathType Leaf) -and (-not $Force)) {

            throw ($localized.ImageAlreadyExistsError -f $Path);
        }
        elseif ((Test-Path -Path $Path -PathType Leaf) -and ($Force)) {

            Dismount-VHD -Path $Path -ErrorAction Stop;
            WriteVerbose ($localized.RemovingDiskImage -f $Path);
            Remove-Item -Path $Path -Force -ErrorAction Stop;
        }

    } #end begin
    process {

        WriteVerbose ($localized.CreatingDiskImage -f $Path);
        [ref] $null = New-Vhd -Path $Path -Dynamic -SizeBytes $Size;
        WriteVerbose ($localized.MountingDiskImage -f $Path);
        $vhdMount = Mount-VHD -Path $Path -Passthru;
        WriteVerbose ($localized.InitializingDiskImage -f $Path);
        [ref] $null = Initialize-Disk -Number $vhdMount.DiskNumber -PartitionStyle $PartitionStyle -PassThru;

        switch ($PartitionStyle) {
            'MBR' {
                NewDiskImageMbr -Vhd $vhdMount;
            }
            'GPT' {
                NewDiskImageGpt -Vhd $vhdMount;
            }
        }

        if ($Passthru) {

            return $vhdMount;
        }
        else {

            Dismount-VHD -Path $Path;
        }

    } #end process
} #end function NewDiskImage


function SetDiskImageBootVolumeMbr {
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
        $bcdEditExe = 'bcdedit.exe';
        $imageName = [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);

        $osPartitionDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType 'IFS';
        WriteVerbose ($localized.RepairingBootVolume -f $osPartitionDriveLetter);
        $bcdBootArgs = @(
            ('{0}:\Windows' -f $osPartitionDriveLetter), # Path to source Windows boot files
            ('/s {0}:\' -f $osPartitionDriveLetter),     # Volume to create the \BOOT folder on.
            '/v'                                         # Enable verbose logging.
            '/f BIOS'                                    # Firmware type of the target system partition
        )
        InvokeExecutable -Path $bcdBootExe -Arguments $bcdBootArgs -LogName ('{0}-BootEdit.log' -f $imageName);

        $bootmgrDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {bootmgr} device locate'
        );
        InvokeExecutable -Path $bcdEditExe -Arguments $bootmgrDeviceArgs -LogName ('{0}-BootmgrDevice.log' -f $imageName);

        $defaultDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {default} device locate'
        );
        InvokeExecutable -Path $bcdEditExe -Arguments $defaultDeviceArgs -LogName ('{0}-DefaultDevice.log' -f $imageName);

        $defaultOsDeviceArgs = @(
            ('/store {0}:\boot\bcd' -f $osPartitionDriveLetter),
            '/set {default} osdevice locate'
        );
        InvokeExecutable -Path $bcdEditExe -Arguments $defaultOsDeviceArgs -LogName ('{0}-DefaultOsDevice.log' -f $imageName);

    } #end process
} #end function


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
} #end function


function SetDiskImageBootVolume {
<#
    .SYNOPSIS
        Sets the boot volume of a mounted disk image.
#>
    [CmdletBinding()]
    param (
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle
    )
    process {

        switch ($PartitionStyle) {

            'MBR' {

                SetDiskImageBootVolumeMbr -Vhd $Vhd;
                break;
            }
            'GPT' {

                SetDiskImageBootVolumeGpt -Vhd $Vhd;
                break;
            }
        } #end switch

    } #end process
} #end function SetDiskImageBootVolume


function AddDiskImageHotfix {
<#
    .SYMOPSIS
        Adds a Windows update/hotfix package to an image.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if ($PartitionStyle -eq 'MBR') {

            $partitionType = 'IFS';
        }
        elseif ($PartitionStyle -eq 'GPT') {

            $partitionType = 'Basic';
        }
        $vhdDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

        $resolveLabMediaParams = @{
            Id = $Id;
        }
        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {
            $resolveLabMediaParams['ConfigurationData'] = $ConfigurationData;
        }
        $media = ResolveLabMedia @resolveLabMediaParams;

        foreach ($hotfix in $media.Hotfixes) {

            $hotfixFileInfo = InvokeLabMediaHotfixDownload -Id $hotfix.Id -Uri $hotfix.Uri;
            $packageName = [System.IO.Path]::GetFileNameWithoutExtension($hotfixFileInfo.FullName);

            AddDiskImagePackage -Name $packageName -Path $hotfixFileInfo.FullName -DestinationPath $vhdDriveLetter;
        }

    } #end process
} #end function AddDiskImageHotfix


function AddDiskImagePackage {
<#
    .SYNOPSIS
        Adds a Windows package (.cab) to an image. This is implmented primarily to support injection of
        packages into Nano server images.
    .NOTES
        The real difference between a hotfix and package is that a package can either be specified in the
        master VHD(X) image creation OR be injected into VHD(X) differencing disk.
#>
    [CmdletBinding()]
    param (
        ## Package name (used for logging)
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## File path to the package (.cab) file
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Destination operating system path (mounted VHD), i.e. G:\
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath
    )
    begin {

        ## We just want the drive letter
        if ($DestinationPath.Length -gt 1) {

            $DestinationPath = $DestinationPath.Substring(0,1);
        }

    }
    process {

        $logPath = '{0}:\Windows\Logs\{1}' -f $DestinationPath, $labDefaults.ModuleName;
        [ref] $null = NewDirectory -Path $logPath -Verbose:$false;

        WriteVerbose ($localized.AddingImagePackage -f $Name, $DestinationPath);
        $addWindowsPackageParams = @{
            PackagePath = $Path;
            Path = '{0}:\' -f $DestinationPath;
            LogPath = '{0}\{1}.log' -f $logPath, $Name;
            LogLevel = 'Errors';
        }
        [ref] $null = Microsoft.Dism.Powershell\Add-WindowsPackage @addWindowsPackageParams -Verbose:$false;

    } #end process
} #end function AddDiskImagePackage

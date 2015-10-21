function ExpandWindowsImage {
<#
    .SYNOPSIS
        Writes a .wim image to a mounted VHD/(X) file.
#>
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param (
        ## ISO file path containing WIM image
        [Parameter(Mandatory)] [System.String] $IsoPath,
        ## WIM image index to apply from the ISO
        [Parameter(Mandatory, ParameterSetName = 'Index')] [System.Int32] $WimImageIndex,
        ## WIM image name to apply from the ISO
        [Parameter(Mandatory, ParameterSetName = 'Name')] [ValidateNotNullOrEmpty()] [System.String] $WimImageName,
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory)] [ValidateNotNull()] [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk
        ## Disk image partition scheme
        [Parameter(Mandatory)] [ValidateSet('MBR','GPT')] [System.String] $PartitionStyle
    )
    process {
        ## Mount ISO
        WriteVerbose ($localized.MountingDiskImage -f $IsoPath);
        $iso = Mount-DiskImage -ImagePath $IsoPath -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
        $iso = Get-DiskImage -ImagePath $iso.ImagePath;
        $isoDriveLetter = $iso | Get-Volume | Select-Object -ExpandProperty DriveLetter;

        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            ## Locate the image index
            $WimImageIndex = GetWindowsImageIndex -IsoDriveLetter $isoDriveLetter -ImageName $WimImageName;
        }

        if ($PartitionStyle -eq 'MBR') { $partitionType = 'IFS'; }
        elseif ($PartitionStyle -eq 'GPT') { $partitionType = 'Basic'; }
        $vhdDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

        $logName = '{0}.log' -f [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);
        $logPath = Join-Path -Path $env:TEMP -ChildPath $logName;
        WriteVerbose ($localized.ApplyingWindowsImage -f $WimImageIndex, $Vhd.Path);
        $expandWindowsImage = @{
            ImagePath = '{0}:\sources\install.wim' -f $isoDriveLetter;
            ApplyPath = '{0}:\' -f $vhdDriveLetter;
            LogPath = $logPath;
            Index = $WimImageIndex;
        }
        $logPath = Expand-WindowsImage @expandWindowsImage -Verbose:$false;
    } #end process
    end {
        ## Dismount ISO
        WriteVerbose ($localized.DismountingDiskImage -f $IsoPath);
        Dismount-DiskImage -ImagePath $IsoPath;
    }
} #end function ExpandWindowsImage

function GetWindowsImageIndex {
<#
    .SYNOPSIS
        Locates the specified WIM image index by its name, i.e. SERVERSTANDARD or SERVERDATACENTERSTANDARD
    .OUTPUTS
        The WIM image index.
#>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        # Mounted ISO drive letter
        [Parameter(Mandatory)] [ValidateLength(1,1)] [System.String] $IsoDriveLetter,
        # Windows image name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $ImageName
    )
    process {
        Get-WindowsImage -ImagePath ('{0}:\sources\install.wim' -f $IsoDriveLetter) |
            Where-Object ImageName -eq $ImageName |
                Select-Object -ExpandProperty ImageIndex;
    } #end process
} #end function GetWindowsImageIndex

function GetWindowsImageName {
<#
    .SYNOPSIS
        Locates the specified WIM image name by its index.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # Mounted ISO path
        [Parameter(Mandatory)] [ValidateLength(1,1)] [System.String] $IsoDriveLetter,
        # Windows image index
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.Int32] $ImageIndex
    )
    process {
        Get-WindowsImage -ImagePath ('{0}:\sources\install.wim' -f $IsoDriveLetter) |
            Where-Object ImageIndex -eq $ImageIndex |
                Select-Object -ExpandProperty ImageName;
    } #end process
} #end function GetWindowsImageName

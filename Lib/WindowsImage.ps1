function ExpandWindowsImage {
<#
    .SYNOPSIS
        Writes a .wim image to a mounted VHD/(X) file.
#>
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param (
        ## File path to WIM file or ISO file containing the WIM image
        [Parameter(Mandatory, ValueFromPipeline)] [System.String] $MediaPath,
        ## WIM image index to apply
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Index')]
        [System.Int32] $WimImageIndex,
        ## WIM image name to apply
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()] [System.String] $WimImageName,
        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()] [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk
        ## Disk image partition scheme
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('MBR','GPT')] [System.String] $PartitionStyle,
        ## Optional Windows features to add to the image after expansion (ISO only)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()] [System.String[]] $WindowsOptionalFeature
    )
    process {
        $mediaFileInfo = Get-Item -Path $MediaPath;
        $wimPath = $MediaPath;

        if ($mediaFileInfo.Extension -eq '.ISO') {
            ## Mount ISO
            WriteVerbose ($localized.MountingDiskImage -f $MediaPath);
            $iso = Mount-DiskImage -ImagePath $MediaPath -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
            $iso = Get-DiskImage -ImagePath $iso.ImagePath;
            $isoDriveLetter = $iso | Get-Volume | Select-Object -ExpandProperty DriveLetter;
            ## Update the media path to point to the mounted ISO
            $wimPath = '{0}:\sources\install.wim' -f $isoDriveLetter;
        }

        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            ## Locate the image index
            $WimImageIndex = GetWindowsImageIndex -ImagePath $wimPath -ImageName $WimImageName;
        }
        
        if ($PartitionStyle -eq 'MBR') { $partitionType = 'IFS'; }
        elseif ($PartitionStyle -eq 'GPT') { $partitionType = 'Basic'; }
        $vhdDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;
        
        $logName = '{0}.log' -f [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);
        $logPath = Join-Path -Path $env:TEMP -ChildPath $logName;
        WriteVerbose ($localized.ApplyingWindowsImage -f $WimImageIndex, $Vhd.Path);
        $expandWindowsImage = @{
            ImagePath = $wimPath;
            ApplyPath = '{0}:\' -f $vhdDriveLetter;
            LogPath = $logPath;
            Index = $WimImageIndex;
        }
        $dismOutput = Expand-WindowsImage @expandWindowsImage -Verbose:$false;
        
        ## Add additional features if required (only supported for ISOs as there's no \SXS folder?)
        if ($mediaFileInfo.Extension -eq '.ISO') {
            if ($WindowsOptionalFeature) {
                $addWindowsOptionalFeatureParams = @{
                    ImagePath = '{0}:\sources\sxs' -f $isoDriveLetter;
                    DestinationPath = '{0}:\' -f $vhdDriveLetter;
                    LogPath = $logPath;
                    WindowsOptionalFeature = $WindowsOptionalFeature;
                }
                $dismOutput = AddWindowsOptionalFeature @addWindowsOptionalFeatureParams;
            }
            ## Dismount ISO
            WriteVerbose ($localized.DismountingDiskImage -f $MediaPath);
            Dismount-DiskImage -ImagePath $MediaPath;
        }
        elseif ($WindowsOptionalFeature) {
            WriteWarning ($localized.UnsupportedConfigurationWarning -f 'WindowsOptionalFeature', 'WIM media');
        }
    } #end process
} #end function ExpandWindowsImage

function AddWindowsOptionalFeature {
<#
    .SYMOPSIS
        Enables Windows optional features to an image.
#>
    [CmdletBinding()]
    param (
        ## Source ISO install.wim
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String] $ImagePath,
        ## Mounted VHD(X) Operating System disk drive
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
        ## Windows features to add to the image after expansion
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()] [System.String[]] $WindowsOptionalFeature,
        ## DISM log path
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $LogPath = $DestinationPath
    )
    process {
        WriteVerbose ($localized.AddingWindowsFeature -f ($WindowsOptionalFeature -join ','), $DestinationPath);
        $enableWindowsOptionalFeatureParams = @{
            Source = $ImagePath;
            Path = $DestinationPath;
            LogPath = $LogPath;
            FeatureName = $WindowsOptionalFeature;
            LimitAccess = $true;
            All = $true;
        }
        $dismOutput = Enable-WindowsOptionalFeature @enableWindowsOptionalFeatureParams -Verbose:$false;
    } #end process
} #end function AddDiskImageOptionalFeature


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
        # WIM image path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String] $ImagePath,
        # Windows image name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.String] $ImageName
    )
    process {
        WriteVerbose ($localized.LocatingWimImageIndex -f $ImageName);
        Get-WindowsImage -ImagePath $ImagePath -Verbose:$false |
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
        # WIM image path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] [System.String] $ImagePath,
        # Windows image index
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [System.Int32] $ImageIndex
    )
    process {
        WriteVerbose ($localized.LocatingWimImageName -f $ImageIndex);
        Get-WindowsImage -ImagePath $ImagePath -Verbose:$false |
            Where-Object ImageIndex -eq $ImageIndex |
                Select-Object -ExpandProperty ImageName;
    } #end process
} #end function GetWindowsImageName

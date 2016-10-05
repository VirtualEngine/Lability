function ExpandWindowsImage {
<#
    .SYNOPSIS
        Writes a .wim image to a mounted VHD/(X) file.
#>
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param (
        ## File path to WIM file or ISO file containing the WIM image
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $MediaPath,

        ## WIM image index to apply
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Index')]
        [System.Int32] $WimImageIndex,

        ## WIM image name to apply
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [System.String] $WimImageName,

        ## Mounted VHD(X) Operating System disk image
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Object] $Vhd, # Microsoft.Vhd.PowerShell.VirtualHardDisk

        ## Disk image partition scheme
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Optional Windows features to add to the image after expansion (ISO only)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String[]] $WindowsOptionalFeature,

        ## Optional Windows features source path
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $SourcePath = '\sources\sxs',

        ## Relative source WIM file path (only used for ISOs)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $WimPath = '\sources\install.wim',

        ## Optional Windows packages to add to the image after expansion (primarily used for Nano Server)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String[]] $Package,

        ## Relative packages (.cab) file path (primarily used for Nano Server)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackagePath = '\packages',

        ## Package localization directory/extension (primarily used for Nano Server)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackageLocale = 'en-US'
    )
    process {

        ## Assume the media path is a literal path to a WIM file
        $windowsImagePath = $MediaPath;
        $mediaFileInfo = Get-Item -Path $MediaPath;

        if ($mediaFileInfo.Extension -eq '.ISO') {
            ## Mount ISO
            WriteVerbose ($localized.MountingDiskImage -f $MediaPath);
            $iso = Mount-DiskImage -ImagePath $MediaPath -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
            $iso = Get-DiskImage -ImagePath $iso.ImagePath;
            $isoDriveLetter = $iso | Get-Volume | Select-Object -ExpandProperty DriveLetter;
            ## Update the media path to point to the mounted ISO
            $windowsImagePath = '{0}:{1}' -f $isoDriveLetter, $WimPath;
        }

        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            ## Locate the image index
            $WimImageIndex = GetWindowsImageIndex -ImagePath $windowsImagePath -ImageName $WimImageName;
        }

        if ($PartitionStyle -eq 'MBR') { $partitionType = 'IFS'; }
        elseif ($PartitionStyle -eq 'GPT') { $partitionType = 'Basic'; }
        $vhdDriveLetter = GetDiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

        $logName = '{0}.log' -f [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);
        $logPath = Join-Path -Path $env:TEMP -ChildPath $logName;
        WriteVerbose ($localized.ApplyingWindowsImage -f $WimImageIndex, $Vhd.Path);
        $expandWindowsImage = @{
            ImagePath = $windowsImagePath;
            ApplyPath = '{0}:\' -f $vhdDriveLetter;
            LogPath = $logPath;
            Index = $WimImageIndex;
        }
        $dismOutput = Expand-WindowsImage @expandWindowsImage -Verbose:$false;

        [ref] $null = Get-PSDrive;

        ## Add additional packages (.cab) files
        if ($Package) {

            ## Default to relative package folder path
            $addWindowsPackageParams = @{
                PackagePath = '{0}:{1}' -f $isoDriveLetter, $PackagePath;
                DestinationPath = '{0}:\' -f $vhdDriveLetter;
                LogPath = $logPath;
                Package = $Package;
                PackageLocale = $PackageLocale;
            }
            if (-not $PackagePath.StartsWith('\')) {
                ## Use the specified/literal path
                $addWindowsPackageParams['PackagePath'] = $PackagePath;
            }
            $dismOutput = AddWindowsPackage @addWindowsPackageParams;

        } #end if Package

        ## Add additional features if required
        if ($WindowsOptionalFeature) {

            ## Default to ISO relative source folder path
            $addWindowsOptionalFeatureParams = @{
                ImagePath = '{0}:{1}' -f $isoDriveLetter, $SourcePath;
                DestinationPath = '{0}:\' -f $vhdDriveLetter;
                LogPath = $logPath;
                WindowsOptionalFeature = $WindowsOptionalFeature;
            }
            if ($mediaFileInfo.Extension -eq '.WIM') {
                ## The Windows optional feature source path for .WIM files is a literal path
                $addWindowsOptionalFeatureParams['ImagePath'] = $SourcePath;
            }
            $dismOutput = AddWindowsOptionalFeature @addWindowsOptionalFeatureParams;
        } #end if WindowsOptionalFeature

        if ($mediaFileInfo.Extension -eq '.ISO') {
            ## Dismount ISO
            WriteVerbose ($localized.DismountingDiskImage -f $MediaPath);
            Dismount-DiskImage -ImagePath $MediaPath;
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
        ## Source package file path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ImagePath,

        ## Mounted VHD(X) Operating System disk drive
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        ## Windows packages to add to the image after expansion
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String[]] $WindowsOptionalFeature,

        ## DISM log path
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LogPath = $DestinationPath
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


function AddWindowsPackage {
<#
    .SYNOPSIS
        Adds a Windows package to an image.
#>
    [CmdletBinding()]
    param (
        ## Windows packages (.cab) files to add to the image after expansion
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String[]] $Package,

        ## Path to the .cab files
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackagePath,

        ## Mounted VHD(X) Operating System disk drive
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        ## Package localization directory/extension (primarily used for Nano Server)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $PackageLocale = 'en-US',

        ## DISM log path
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LogPath = $DestinationPath
    )
    process {

        foreach ($packageName in $Package) {

            WriteVerbose ($localized.AddingWindowsPackage -f $packagename, $DestinationPath);
            $packageFilename = '{0}.cab' -f $packageName;
            $packageFilePath = Join-Path -Path $PackagePath -ChildPath $packageFilename;
            AddDiskImagePackage -Name $packageName -Path $packageFilePath -DestinationPath $DestinationPath;

            ## Check for language-specific package (Change from Server 2016 TP releases and Server 2016 Nano RTM)
            if ($PSBoundParameters.ContainsKey('PackageLocale')) {

                $localizedPackageName = '{0}_{1}' -f $packageName, $packageLocale;
                $localizedPackageFilename = '{0}.cab' -f $localizedPackageName;
                $localizedPackageDirectoryPath = Join-Path -Path $PackagePath -ChildPath $PackageLocale;
                $localizedPackagePath = Join-Path -Path $localizedPackageDirectoryPath -ChildPath $localizedPackageFilename;
                if (Test-Path -Path $localizedPackagePath -PathType Leaf) {

                    WriteVerbose ($localized.AddingLocalizedWindowsPackage -f $localizedPackageName, $DestinationPath);
                    $addDiskImagePackageParams = @{
                        Name = $localizedPackageName;
                        Path = $localizedPackagePath;
                        DestinationPath = $DestinationPath;
                    }
                    AddDiskImagePackage @addDiskImagePackageParams;
                }
            }

        } #end foreach package

    } #end process
} #end function AddWindowsPackage


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
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $ImagePath,

        # Windows image name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $ImageName
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
        [ValidateNotNullOrEmpty()]
        [System.String] $ImagePath,

        # Windows image index
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Int32] $ImageIndex
    )
    process {

        WriteVerbose ($localized.LocatingWimImageName -f $ImageIndex);
        Get-WindowsImage -ImagePath $ImagePath -Verbose:$false |
            Where-Object ImageIndex -eq $ImageIndex |
                Select-Object -ExpandProperty ImageName;

    } #end process
} #end function GetWindowsImageName

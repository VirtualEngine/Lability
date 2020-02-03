function Expand-LabImage {
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

        try {

            if ($mediaFileInfo.Extension -eq '.ISO') {

                ## Disable BitLocker fixed drive write protection (if enabled)
                Disable-BitLockerFDV;

                ## Mount ISO
                Write-Verbose -Message ($localized.MountingDiskImage -f $MediaPath);
                $mountDiskImageParams = @{
                    ImagePath = $MediaPath;
                    StorageType = 'ISO';
                    Access = 'ReadOnly';
                    PassThru = $true;
                    Verbose = $false;
                    ErrorAction = 'Stop';
                }
                $iso = Storage\Mount-DiskImage @mountDiskImageParams;
                $iso = Storage\Get-DiskImage -ImagePath $iso.ImagePath;
                $isoDriveLetter = Storage\Get-Volume -DiskImage $iso | Select-Object -ExpandProperty DriveLetter;

                ## Update the media path to point to the mounted ISO
                $windowsImagePath = '{0}:{1}' -f $isoDriveLetter, $WimPath;
            }

            if ($PSCmdlet.ParameterSetName -eq 'Name') {

                ## Locate the image index
                $wimImageIndex = Get-WindowsImageByName -ImagePath $windowsImagePath -ImageName $WimImageName;
            }

            if ($PartitionStyle -eq 'MBR') {

                $partitionType = 'IFS';
            }
            elseif ($PartitionStyle -eq 'GPT') {

                $partitionType = 'Basic';
            }
            $vhdDriveLetter = Get-DiskImageDriveLetter -DiskImage $Vhd -PartitionType $partitionType;

            $logName = '{0}.log' -f [System.IO.Path]::GetFileNameWithoutExtension($Vhd.Path);
            $logPath = Join-Path -Path $env:TEMP -ChildPath $logName;
            Write-Verbose -Message ($localized.ApplyingWindowsImage -f $wimImageIndex, $Vhd.Path);

            $expandWindowsImageParams = @{
                ImagePath = $windowsImagePath;
                ApplyPath = '{0}:\' -f $vhdDriveLetter;
                LogPath = $logPath;
                Index = $wimImageIndex;
                Verbose = $false;
                ErrorAction = 'Stop';
            }
            [ref] $null = Expand-WindowsImage @expandWindowsImageParams;
            [ref] $null = Get-PSDrive;

            ## Add additional packages (.cab) files
            if ($Package) {

                ## Default to relative package folder path
                $addLabImageWindowsPackageParams = @{
                    PackagePath = '{0}:{1}' -f $isoDriveLetter, $PackagePath;
                    DestinationPath = '{0}:\' -f $vhdDriveLetter;
                    LogPath = $logPath;
                    Package = $Package;
                    PackageLocale = $PackageLocale;
                    ErrorAction = 'Stop';
                }
                if (-not $PackagePath.StartsWith('\')) {

                    ## Use the specified/literal path
                    $addLabImageWindowsPackageParams['PackagePath'] = $PackagePath;
                }
                [ref] $null = Add-LabImageWindowsPackage @addLabImageWindowsPackageParams;

            } #end if Package

            ## Add additional features if required
            if ($WindowsOptionalFeature) {

                ## Default to ISO relative source folder path
                $addLabImageWindowsOptionalFeatureParams = @{
                    ImagePath = '{0}:{1}' -f $isoDriveLetter, $SourcePath;
                    DestinationPath = '{0}:\' -f $vhdDriveLetter;
                    LogPath = $logPath;
                    WindowsOptionalFeature = $WindowsOptionalFeature;
                    ErrorAction = 'Stop';
                }
                if ($mediaFileInfo.Extension -eq '.WIM') {

                    ## The Windows optional feature source path for .WIM files is a literal path
                    $addLabImageWindowsOptionalFeatureParams['ImagePath'] = $SourcePath;
                }
                [ref] $null = Add-LabImageWindowsOptionalFeature @addLabImageWindowsOptionalFeatureParams;
            } #end if WindowsOptionalFeature

        }
        catch {

            Write-Error -Message $_;

        } #end catch
        finally {

            if ($mediaFileInfo.Extension -eq '.ISO') {

                ## Always dismount ISO (#166)
                Write-Verbose -Message ($localized.DismountingDiskImage -f $MediaPath);
                $null = Storage\Dismount-DiskImage -ImagePath $MediaPath;
            }

            ## Enable BitLocker (if required)
            Assert-BitLockerFDV

        } #end finally

    } #end process
} #end function Expand-LabImage

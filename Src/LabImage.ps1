function Get-LabImage {
<#
    .SYNOPSIS
        Gets master/parent image.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'Id')] [ValidateNotNullOrEmpty()] [System.String] $Id
    )
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $parentVhdPath = $hostDefaults.ParentVhdPath;
        $filter = '*.vhdx';
        if ($Id) { $filter = '{0}.vhdx' -f $Id; }
        $ids = Get-ChildItem -Path $parentVhdPath -Filter $filter;
        foreach ($image in $ids) {
            if (Test-Path -Path $image.FullName -PathType Leaf) {
                $diskImage = Get-DiskImage -ImagePath $image.FullName;
                $labImage = [PSCustomObject] @{
                    Id = $image.BaseName;
                    Attached = $diskImage.Attached;
                    ImagePath = $diskImage.ImagePath;
                    LogicalSectorSize = $diskImage.LogicalSectorSize;
                    BlockSize = $diskImage.BlockSize;
                    FileSize = $diskImage.FileSize;
                    Size = $diskImage.Size;
                }
                Write-Output $labImage;
            }
        } #end foreach $image
    } #end process
} #end function Get-LabImage

function Test-LabImage {
<#
    .SYNOPSIS
        Tests whether a master/parent image is available.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()] [System.String] $Id
    )
    process {
        if (Get-LabImage -Id $Id) { return $true; }
        else { return $false; }
    } #end process
} #end function Test-LabImage

function New-LabImage {
<#
    .SYNOPSIS
        Creates a new master/parent image.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Id,
        [Parameter()] [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        if ((Test-LabImage -Id $Id) -and $Force) {
            $image = Get-LabImage -Id $Id;
            WriteVerbose ($localized.RemovingDiskImage -f $image.ImagePath);
            Remove-Item -Path $image.ImagePath -Force -ErrorAction Stop;
        }
        elseif (Test-LabImage -Id $Id) {
            throw ($localized.ImageAlreadyExistsError -f $Id);
        }
        ## Download media if required..
        $isoFileInfo = InvokeLabMediaImageDownload -Id $Id;
    }
    process {
        $hostDefaults = GetConfigurationData -Configuration Host;
        $media = Get-LabMedia -Id $Id;
        WriteVerbose ($localized.CreatingDiskImage -f $media.Description);
        $imageName = '{0}.vhdx' -f $Id;
        $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName;
        if ($media.Architecture -eq 'x86') { $partitionStyle = 'MBR'; }
        else { $partitionStyle = 'GPT'; }

        ## TODO: Add try/catch and delete parent VHDX if the process fails...

        ## Create VHDX
        $image = NewDiskImage -Path $imagePath -PartitionStyle $partitionStyle -Passthru -Force;
        ## Refresh PSDrives
        [ref] $null = Get-PSDrive;
        ## Apply WIM (ExpandWindowsImage)
        ExpandWindowsImage -IsoPath $isoFileInfo.FullName -WimImageName $media.ImageName -Vhd $image -PartitionStyle $partitionStyle;
        ## Apply hotfixes (AddDiskImagePackage)
        AddDiskImagePackage -Id $Id -Vhd $image -PartitionStyle $partitionStyle;
        ## Configure boot volume (SetDiskImageBootVolume)
        SetDiskImageBootVolume -Vhd $image -PartitionStyle $partitionStyle;
        ## Dismount VHDX
        Dismount-VHD -Path $imagePath;
    } #end process
} #end function New-LabImage

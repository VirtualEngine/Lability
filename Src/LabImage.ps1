function Get-LabImage {
<#
    .SYNOPSIS
        Gets master/parent disk image.
    .DESCRIPTION
        The Get-LabImage cmdlet returns current master/parent disk image properties.
    .PARAMETER Id
        Specifies the media Id of the image to return. If this parameter is not specified, all images are returned.
    .EXAMPLE
        Get-LabImage
        
        Returns all current lab images on the host.
    .EXAMPLE
        Get-LabImage -Id 2012R2_x64_Standard_EN_Eval
        
        Returns the '2012R2_x64_Standard_EN_Eval' lab image properties, if available.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Id
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
                Write-Output -InputObject $labImage;
            }
        } #end foreach $image
    } #end process
} #end function Get-LabImage

function Test-LabImage {
<#
    .SYNOPSIS
        Tests whether a master/parent lab image is present.
    .DESCRIPTION
        The Test-LabImage cmdlet returns whether a specified disk image is present.
    .PARAMETER Id
        Specifies the media Id of the image to test.
    .EXAMPLE
        Test-LabImage -Id 2012R2_x64_Standard_EN_Eval
        
        Tests whether the '-Id 2012R2_x64_Standard_EN_Eval' lab image is present.
    .LINK
        Get-LabImage
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Id
    )
    process {
        if (Get-LabImage -Id $Id) { return $true; }
        else { return $false; }
    } #end process
} #end function Test-LabImage

function New-LabImage {
<#
    .SYNOPSIS
        Creates a new master/parent lab image.
    .DESCRIPTION
        The New-LabImage cmdlet starts the creation of a lab VHD(X) master image from the specified media Id.
        
        Lability will automatically create lab images as required. If there is a need to manally recreate an image,
        then the New-LabImage cmdlet can be used.
    .PARAMETER Id
        Specifies the media Id of the image to create.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains the required media definition.
    .PARAMETER Force
        Specifies that any existing image should be overwritten.
    .EXAMPLE
        New-LabImage -Id 2012R2_x64_Standard_EN_Eval
        
        Creates the VHD(X) image from the '2012R2_x64_Standard_EN_Eval' media Id.
    .EXAMPLE
        New-LabImage -Id 2012R2_x64_Standard_EN_Eval -Force
        
        Creates the VHD(X) image from the '2012R2_x64_Standard_EN_Eval' media Id, overwriting an existing image with the same name.
    .LINK
        Get-LabMedia
        Get-LabImage
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param (
        ## Lab media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Id,
        
        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,
        
        ## Force the re(creation) of the master/parent image
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        if ((Test-LabImage -Id $Id) -and $Force) {
            $image = Get-LabImage -Id $Id;
            WriteVerbose ($localized.RemovingDiskImage -f $image.ImagePath);
            [ref] $null = Remove-Item -Path $image.ImagePath -Force -ErrorAction Stop;
        }
        elseif (Test-LabImage -Id $Id) {
            throw ($localized.ImageAlreadyExistsError -f $Id);
        }
    }
    process {
        ## Download media if required..
        [ref] $null = $PSBoundParameters.Remove('Force');
        [ref] $null = $PSBoundParameters.Remove('WhatIf');
        [ref] $null = $PSBoundParameters.Remove('Confirm');
        $media = ResolveLabMedia @PSBoundParameters;
        $mediaFileInfo = InvokeLabMediaImageDownload -Media $media;
        
        $hostDefaults = GetConfigurationData -Configuration Host;
        
        WriteVerbose ($localized.CreatingDiskImage -f $media.Description);
        $imageName = '{0}.vhdx' -f $Id;
        $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName;
        $imageCreationFailed = $false;

        try {
            ## Create VHDX
            if ($media.CustomData.PartitionStyle) {
                ## Custom partition style has been defined so use that
                $partitionStyle = $media.CustomData.PartitionStyle;
            }
            elseif ($media.Architecture -eq 'x86') {
                ## Otherwise default to MBR for x86 media
                $partitionStyle = 'MBR';
            }
            else {
                $partitionStyle = 'GPT';
            }
            
            ## Create disk image and refresh PSDrives
            $image = NewDiskImage -Path $imagePath -PartitionStyle $partitionStyle -Passthru -Force -ErrorAction Stop;
            [ref] $null = Get-PSDrive;
            
            ## Apply WIM (ExpandWindowsImage) and add specified features
            $expandWindowsImageParams = @{
                Vhd = $image;
                MediaPath = $mediaFileInfo.FullName;
                PartitionStyle = $partitionStyle;
            }
            
            ## Determine whether we're using the WIM image index or image name. This permits
            ## specifying an integer image index in a media's 'ImageName' property.
            [System.Int32] $wimImageIndex = $null;
            if ([System.Int32]::TryParse($media.ImageName, [ref] $wimImageIndex)) {
                $expandWindowsImageParams['WimImageIndex'] = $wimImageIndex;
            }
            else {
                $expandWindowsImageParams['WimImageName'] = $media.ImageName;
            }

            if ($media.CustomData.SourcePath) {
                $expandWindowsImageParams['SourcePath'] = $media.CustomData.SourcePath;
            }
            if ($media.CustomData.WimPath) {
                $expandWindowsImageParams['WimPath'] = $media.CustomData.WimPath;
            }
            if ($media.CustomData.WindowsOptionalFeature) {
                $expandWindowsImageParams['WindowsOptionalFeature'] = $media.CustomData.WindowsOptionalFeature;
            }
            if ($media.CustomData.PackagePath) {
                $expandWindowsImageParams['PackagePath'] = $media.CustomData.PackagePath;
            }
            if ($media.CustomData.Package) {
                $expandWindowsImageParams['Package'] = $media.CustomData.Package;
            }

            ExpandWindowsImage @expandWindowsImageParams;
            ## Apply hotfixes (AddDiskImageHotfix)
            AddDiskImageHotfix -Id $Id -Vhd $image -PartitionStyle $partitionStyle;
            ## Configure boot volume (SetDiskImageBootVolume)
            SetDiskImageBootVolume -Vhd $image -PartitionStyle $partitionStyle;
        }
        catch {
            ## Have to ensure VHDX is dismounted before we can delete!
            $imageCreationFailed = $true;
            Write-Error -Message $_;
        }
        finally {
            ## Dismount VHDX
            Dismount-VHD -Path $imagePath;
        }

        if ($imageCreationFailed -eq $true) {
            WriteWarning ($localized.RemovingIncompleteImageWarning -f $imagePath);
            Remove-Item -Path $imagePath -Force;
        }
        return (Get-Item -Path $imagePath -ErrorAction Ignore);

    } #end process
} #end function New-LabImage

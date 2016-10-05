function Get-LabImage {
<#
    .SYNOPSIS
        Gets master/parent disk image.
    .DESCRIPTION
        The Get-LabImage cmdlet returns current master/parent disk image properties.
    .PARAMETER Id
        Specifies the media Id of the image to return. If this parameter is not specified, all images are returned.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains the required media definition.
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
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $hostDefaults = GetConfigurationData -Configuration Host;
        $parentVhdPath = ResolvePathEx -Path $hostDefaults.ParentVhdPath;

        if ($PSBoundParameters.ContainsKey('Id')) {

            ## We have an Id. so resolve that
            try {

                $labMedia = ResolveLabMedia @PSBoundParameters;
            }
            catch {

                $labMedia = $null;
            }
        }
        else {
            ## Otherwise return all media
            $labMedia = Get-LabMedia;
        }

        foreach ($media in $labMedia) {

            $differencingVhdPath = '{0}.vhdx' -f $media.Id;
            if ($media.MediaType -eq 'VHD') {

                $differencingVhdPath = $media.Filename;
            }

            $imagePath = Join-Path -Path $parentVhdPath -ChildPath $differencingVhdPath;
            if (Test-Path -Path $imagePath -PathType Leaf) {

                $imageFileInfo = Get-Item -Path $imagePath;
                $diskImage = Get-DiskImage -ImagePath $imageFileInfo.FullName;
                $labImage = [PSCustomObject] @{
                    Id = $media.Id;
                    Attached = $diskImage.Attached;
                    ImagePath = $diskImage.ImagePath;
                    LogicalSectorSize = $diskImage.LogicalSectorSize;
                    BlockSize = $diskImage.BlockSize;
                    FileSize = $diskImage.FileSize;
                    Size = $diskImage.Size;
                    Generation = ($imagePath.Split('.')[-1]).ToUpper();
                }

                $labImage.PSObject.TypeNames.Insert(0, 'VirtualEngine.Lability.Image');
                Write-Output -InputObject $labImage;
            }

        } #end foreach media

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
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains the required media definition.
    .EXAMPLE
        Test-LabImage -Id 2012R2_x64_Standard_EN_Eval

        Tests whether the '-Id 2012R2_x64_Standard_EN_Eval' lab image is present.
    .LINK
        Get-LabImage
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if (Get-LabImage @PSBoundParameters) {

            return $true;
        }
        else {

            return $false;
        }

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
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## Lab media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
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
    process {

        ## Download media if required..
        [ref] $null = $PSBoundParameters.Remove('Force');
        [ref] $null = $PSBoundParameters.Remove('WhatIf');
        [ref] $null = $PSBoundParameters.Remove('Confirm');

        if ((Test-LabImage @PSBoundParameters) -and $Force) {

            $image = Get-LabImage @PSBoundParameters;
            WriteVerbose ($localized.RemovingDiskImage -f $image.ImagePath);
            [ref] $null = Remove-Item -Path $image.ImagePath -Force -ErrorAction Stop;
        }
        elseif (Test-LabImage @PSBoundParameters) {

            throw ($localized.ImageAlreadyExistsError -f $Id);
        }

        $media = ResolveLabMedia @PSBoundParameters;
        $mediaFileInfo = InvokeLabMediaImageDownload -Media $media;
        $hostDefaults = GetConfigurationData -Configuration Host;

        if ($media.MediaType -eq 'VHD') {

            WriteVerbose ($localized.ImportingExistingDiskImage -f $media.Description);
            $imageName = $media.Filename;
            $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName;
        } #end if VHD
        else {

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

            WriteVerbose ($localized.CreatingDiskImage -f $media.Description);
            $imageName = '{0}.vhdx' -f $Id;
            $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName;

            ## Apply WIM (ExpandWindowsImage) and add specified features
            $expandWindowsImageParams = @{
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

                if ([System.String]::IsNullOrEmpty($media.ImageName)) {
                    throw ($localized.ImageNameRequiredError -f 'ImageName');
                }

                $expandWindowsImageParams['WimImageName'] = $media.ImageName;
            }

            $imageCreationFailed = $false;

            try {

                ## Create disk image and refresh PSDrives
                $newDiskImageParams = @{
                    Path = $imagePath;
                    PartitionStyle = $partitionStyle;
                    Passthru = $true;
                    Force = $true;
                    ErrorAction = 'Stop';
                }
                $image = NewDiskImage @newDiskImageParams;
                [ref] $null = Get-PSDrive;

                $expandWindowsImageParams['Vhd'] = $image;

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
                $addDiskImageHotfixParams = @{
                    Id = $Id;
                    Vhd = $image;
                    PartitionStyle = $partitionStyle;
                }
                if ($PSBoundParameters.ContainsKey('ConfigurationData')) {
                    $addDiskImageHotfixParams['ConfigurationData'] = $ConfigurationData;
                }
                AddDiskImageHotfix @addDiskImageHotfixParams;

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
        } #end if ISO/WIM

        return (Get-LabImage $PSBoundParameters);

    } #end process
} #end function New-LabImage

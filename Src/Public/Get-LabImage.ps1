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

        $hostDefaults = Get-ConfigurationData -Configuration Host;
        $parentVhdPath = Resolve-PathEx -Path $hostDefaults.ParentVhdPath;

        if ($PSBoundParameters.ContainsKey('Id')) {

            ## We have an Id. so resolve that
            try {

                $labMedia = Resolve-LabMedia @PSBoundParameters;
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
                $diskImage = Storage\Get-DiskImage -ImagePath $imageFileInfo.FullName;
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

function Test-LabMedia {

<#
    .SYNOPSIS
        Tests whether lab media has already been successfully downloaded.
    .DESCRIPTION
        The Test-LabMedia cmdlet will check whether the specified media Id has been downloaded and its checksum is correct.
    .PARAMETER Id
        Specifies the media Id to test.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id
    )
    process {

        $hostDefaults = GetConfigurationData -Configuration Host;
        $media = Get-LabMedia -Id $Id;
        if ($media) {

            if (-not $hostDefaults.DisableLocalFileCaching) {

                $testResourceDownloadParams = @{
                    DestinationPath = Join-Path -Path $hostDefaults.IsoPath -ChildPath $media.Filename;
                    Uri = $media.Uri;
                    Checksum = $media.Checksum;
                }
                return TestResourceDownload @testResourceDownloadParams;
            }
            else {

                ## Local file resource caching is disabled
                return $true;
            }
        }
        else {

            return $false;
        }

    } #end process

}


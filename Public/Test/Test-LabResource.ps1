function Test-LabResource {

<#
    .SYNOPSIS
        Tests whether a lab's resources are present.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab resource Id to test.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId,

        ## Lab resource path
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $ResourcePath
    )
    begin {

        if (-not $ResourcePath) {
            $hostDefaults = GetConfigurationData -Configuration Host;
            $ResourcePath = $hostDefaults.ResourcePath;
        }

    }
    process {

        if ($resourceId) {

            $resources = ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $ResourceId;
        }
        else {

            $resources = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource;
        }

        foreach ($resource in $resources) {

            $fileName = $resource.Id;
            if ($resource.Filename) { $fileName = $resource.Filename; }

            $testResourceDownloadParams = @{
                DestinationPath = Join-Path -Path $ResourcePath -ChildPath $fileName;;
                Uri = $resource.Uri;
            }

            if ($resource.Checksum) {

                $testResourceDownloadParams['Checksum'] = $resource.Checksum;
            }

            if (-not (TestResourceDownload @testResourceDownloadParams)) {

                return $false;
            }
        } #end foreach resource

        return $true;

    } #end process

}


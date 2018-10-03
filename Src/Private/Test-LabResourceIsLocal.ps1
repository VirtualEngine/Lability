function Test-LabResourceIsLocal {
<#
    .SYNOPSIS
        Test whether a lab resource is available locally
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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId,

        ## Node's target resource folder
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $LocalResourcePath
    )
    process {

        $resource = Resolve-LabResource -ConfigurationData $ConfigurationData -ResourceId $ResourceId;

        if (($resource.Expand) -and ($resource.Expand -eq $true)) {

            ## Check the ResourceId folder is present
            $resourcePath = Join-Path -Path $LocalResourcePath -ChildPath $resourceId;
            $resourceExtension = [System.IO.Path]::GetExtension($resource.Filename);

            switch ($resourceExtension) {
                '.iso' {
                    $isPresent = Test-Path -Path $resourcePath -PathType Container;
                }
                '.zip' {
                    $isPresent = Test-Path -Path $resourcePath -PathType Container;
                }
                default {
                    throw ($localized.ExpandNotSupportedError -f $resourceExtension);
                }
            }
        }
        else {

            $resourcePath = Join-Path -Path $LocalResourcePath -ChildPath $resource.Filename;
            $isPresent = Test-Path -Path $resourcePath -PathType Leaf;
        }

        if ($isPresent) {

            Write-Verbose -Message ($localized.ResourceFound -f $resourcePath);
            return $true;
        }
        else {

            Write-Verbose -Message ($localized.ResourceNotFound -f $resourcePath);
            return $false;
        }

    } #end process
} #end function

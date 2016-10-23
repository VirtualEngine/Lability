function InvokeModuleDownloadFromPSGallery {

<#
    .SYNOPSIS
        Downloads a PowerShell module/DSC resource from the PowerShell gallery to the host's module cache.
#>
    [CmdletBinding(DefaultParameterSetName = 'LatestAvailable')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath = (GetConfigurationData -Configuration Host).ModuleCachePath,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## Catch all, for splatting parameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $destinationModuleName = '{0}.zip' -f $Name;
        $moduleCacheDestinationPath = Join-Path -Path $DestinationPath -ChildPath $destinationModuleName;
        $setResourceDownloadParams = @{
            DestinationPath = $moduleCacheDestinationPath;
            Uri = ResolvePSGalleryModuleUri @PSBoundParameters;
            NoCheckSum = $true;
        }
        $moduleDestinationPath = SetResourceDownload @setResourceDownloadParams;
        return (RenameModuleCacheVersion -Name $Name -Path $moduleDestinationPath);

    } #end process

}


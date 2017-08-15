function Invoke-LabModuleDownloadFromPSGallery {
<#
    .SYNOPSIS
        Downloads a PowerShell module/DSC resource from the PowerShell gallery to the host's module cache.
#>
    [CmdletBinding(DefaultParameterSetName = 'LatestAvailable')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath = (Get-ConfigurationData -Configuration Host).ModuleCachePath,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'MinimumVersion')]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'RequiredVersion')]
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
            Uri = Resolve-PSGalleryModuleUri @PSBoundParameters;
            NoCheckSum = $true;
        }
        $moduleDestinationPath = SetResourceDownload @setResourceDownloadParams;
        return (Rename-LabModuleCacheVersion -Name $Name -Path $moduleDestinationPath);

    } #end process
} #end function

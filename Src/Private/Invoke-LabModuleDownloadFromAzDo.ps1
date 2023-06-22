function Invoke-LabModuleDownloadFromAzDo {
    <#
    .SYNOPSIS
        Downloads a PowerShell module/DSC resource from an Azure DevOps Feed to the host's module cache.
#>
    [CmdletBinding(DefaultParameterSetName = 'Latest')]
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

        ## Credentials to access the an Azure DevOps private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential,

        ## Catch all, for splatting parameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments

    )
    process {

        $destinationModuleName = '{0}.zip' -f $Name;
        $moduleCacheDestinationPath = Join-Path -Path $DestinationPath -ChildPath $destinationModuleName;

        # we need to remove the property to pass all remaing arguments else the credentials are not passed
        $null = $PSBoundParameters.Remove('RemainingArguments');

        $setResourceDownloadParams = @{
            DestinationPath = $moduleCacheDestinationPath;
            Uri             = Resolve-AzDoModuleUri @PSBoundParameters;
            NoCheckSum      = $true;
            FeedCredential  = $FeedCredential;
        }

        $moduleDestinationPath = Set-ResourceDownload @setResourceDownloadParams;

        $renameLabModuleCacheVersionParams = @{
            Name = $Name;
            Path = $moduleDestinationPath;
        }
        if ($PSBoundParameters.ContainsKey('RequiredVersion')) {

            $renameLabModuleCacheVersionParams['RequiredVersion'] = $RequiredVersion
        }
        elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {

            $renameLabModuleCacheVersionParams['MinimumVersion'] = $MinimumVersion
        }
        return (Rename-LabModuleCacheVersion @renameLabModuleCacheVersionParams);

    } #end process
} #end function

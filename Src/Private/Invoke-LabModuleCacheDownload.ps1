function Invoke-LabModuleCacheDownload {
<#
    .SYNOPSIS
        Downloads a PowerShell module (DSC resource) into the module cache.
#>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [System.String] $Name,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [System.Version] $RequiredVersion,

        ## GitHub repository owner
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Owner,

        ## The GitHub repository name, normally the DSC module's name
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Repository = $Name,

        ## GitHub repository branch
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch,

        ## Source Filesystem module path
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Provider used to download the module
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateSet('PSGallery','GitHub','AzDo','FileSystem')]
        [System.String] $Provider,

        ## Lability PowerShell module info hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Module')]
        [System.Collections.Hashtable[]] $Module,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath = (Get-ConfigurationData -Configuration Host).ModuleCachePath,

        ## Credentials to access the an Azure DevOps private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential,

        ## Force a download of the module(s) even if they already exist in the cache.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments

    )
    begin {

        ## Remove -RemainingArguments to stop it being passed on.
        [ref] $null = $PSBoundParameters.Remove('RemainingArguments');
        if ($PSCmdlet.ParameterSetName -ne 'Module') {

            ## Create a module hashtable
            $newModule = @{
                Name = $Name;
                Repository = $Repository;
            }
            if ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                $newModule['MinimumVersion'] = $MinimumVersion;
            }
            if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                $newModule['RequiredVersion'] = $RequiredVersion;
            }
            if ($PSBoundParameters.ContainsKey('Owner')) {
                $newModule['Owner'] = $Owner;
            }
            if ($PSBoundParameters.ContainsKey('Branch')) {
                $newModule['Branch'] = $Branch;
            }
            if ($PSBoundParameters.ContainsKey('Path')) {
                $newModule['Path'] = $Path;
            }
            if ($PSBoundParameters.ContainsKey('Provider')) {
                $newModule['Provider'] = $Provider;
            }
            $Module = $newModule;
        }

    }
    process {

        foreach ($moduleInfo in $Module) {

            if ((-not (Test-LabModuleCache @moduleInfo)) -or ($Force) -or ($moduleInfo.Latest -eq $true)) {

                if ($moduleInfo.ContainsKey('RequiredVersion')) {
                    Write-Verbose -Message ($localized.ModuleVersionNotCached -f $moduleInfo.Name, $moduleInfo.RequiredVersion);
                }
                elseif ($moduleInfo.ContainsKey('MinimumVersion')) {
                    Write-Verbose -Message ($localized.ModuleMinmumVersionNotCached -f $moduleInfo.Name, $moduleInfo.MinimumVersion);
                }
                else {
                    Write-Verbose -Message ($localized.ModuleNotCached -f $moduleInfo.Name);
                }

                if ((-not $moduleInfo.ContainsKey('Provider')) -or ($moduleInfo['Provider'] -eq 'PSGallery')) {
                    Invoke-LabModuleDownloadFromPSGallery @moduleInfo;
                }
                elseif ($moduleInfo['Provider'] -eq 'AzDo') {
                    Invoke-LabModuleDownloadFromAzDo @moduleInfo -FeedCredential $FeedCredential
                }
                elseif ($moduleInfo['Provider'] -eq 'GitHub') {
                    Invoke-LabModuleDownloadFromGitHub @moduleInfo;
                }
                elseif ($moduleInfo['Provider'] -eq 'FileSystem') {
                    ## We should never get here as filesystem modules are not cached.
                    ## If the test doesn't throw, it should return $true.
                }
            }
            else {
                Get-LabModuleCache @moduleInfo;
            }

        } #end foreach module

    } #end process
} #end function

function Invoke-LabModuleDownloadFromGitHub {
<#
.SYNOPSIS
    Downloads a DSC resource if it has not already been downloaded from Github.
.NOTES
    Uses the GitHubRepository module!
#>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        ## PowerShell DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath = (Get-ConfigurationData -Configuration Host).ModuleCachePath,


        ## The GitHub repository owner, typically 'PowerShell'
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Owner,

        ## The GitHub repository name, normally the DSC module's name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Repository = $Name,

        ## The GitHub branch to download, defaults to the 'master' branch
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch = 'master',

        ## Override the local directory name. Only used if the repository name does not
        ## match the DSC module name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OverrideRepositoryName = $Name,

        ## Force a download, overwriting any existing resources
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Catch all, for splatting parameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    begin {

        if (-not $PSBoundParameters.ContainsKey('Owner')) {
            throw ($localized.MissingParameterError -f 'Owner');
        }
        if (-not $PSBoundParameters.ContainsKey('Branch')) {
            Write-Warning -Message ($localized.NoModuleBranchSpecified -f $Name);
        }

        ## Remove -RemainingArguments to stop it being passed on.
        [ref] $null = $PSBoundParameters.Remove('RemainingArguments');
        ## Add Repository and Branch as they might not have been explicitly passed.
        $PSBoundParameters['Repository'] = $Repository;
        $PSBoundParameters['Branch'] = $Branch;

    }
    process {

        ## GitHub modules are suffixed with .Owner_Branch.zip
        $destinationModuleName = '{0}_{1}_{2}.zip' -f $Name, $Owner, $Branch;
        $moduleCacheDestinationPath = Join-Path -Path $DestinationPath -ChildPath $destinationModuleName;
        $setResourceDownloadParams = @{
            DestinationPath = $moduleCacheDestinationPath;
            Uri = Resolve-GitHubModuleUri @PSBoundParameters;
            NoCheckSum = $true;
        }
        $moduleDestinationPath = Set-ResourceDownload @setResourceDownloadParams;
        return (Rename-LabModuleCacheVersion -Name $Name -Path $moduleDestinationPath -Owner $Owner -Branch $Branch);

    } #end process
} #end function

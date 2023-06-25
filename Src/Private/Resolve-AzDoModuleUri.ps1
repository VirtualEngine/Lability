function Resolve-AzDoModuleUri {
    <#
       .SYNOPSIS
           Returns the direct download Uri for a PowerShell module hosted
           on the Azure DevOps Artifacts.
   #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## PowerShell DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The minimum version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the DSC module required
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## Direct download Uri
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential,

        ## Catch all, for splatting $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        if ($PSBoundParameters.ContainsKey('Uri')) {

            $psRepositoryUri = $Uri;
        }
        else {

            $psRepositoryUri = (Get-ConfigurationData -Configuration Host).RepositoryUri;
        }

        if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
            ## Download the specific version
            ## you would expect to be able to use $RequiredVersion as the version
            ## However this fails if a 4 part version is used as Azure Artifcates always uses 3 part versions
            return ('{0}?id={1}&version={2}' -f $psRepositoryUri, $Name.ToLower(), "$($RequiredVersion.Major).$($RequiredVersion.Minor).$($RequiredVersion.Build)")
        }
        else {

            ## Find the latest package versions
            $invokeRestMethodParams = @{
                Uri = "{0}/FindPackagesById()?id='{1}'" -f $psRepositoryUri, $Name.ToLower()
            }
            if ($PSBoundParameters.ContainsKey('FeedCredential')) {
                $invokeRestMethodParams['Credential'] = $FeedCredential
            }
            $azDoPackages = Invoke-RestMethod @invokeRestMethodParams

            ## Find and return the latest version
            $lastestDoPackageVersion = $azDoPackages | ForEach-Object {
                $_.properties.NormalizedVersion -as [System.Version] } |
            Sort-Object | Select-Object -Last 1
            return ('{0}?id={1}&version={2}' -f $psRepositoryUri, $Name.ToLower(), $lastestDoPackageVersion.ToString())
        }

    } #end process
} #end function Resolve-AzDoModuleUri.ps1

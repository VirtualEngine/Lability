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

Â Â Â Â Â  if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
Â Â Â Â Â Â Â Â Â Â Â  ## Download the specific version
Â          Â Â return ('{0}?id={1}&version={2}' -f $psRepositoryUri, $Name.ToLower(), "$($RequiredVersion.Major).$($RequiredVersion.Minor).$($RequiredVersion.Build)")
Â Â Â Â Â Â Â  }
Â Â Â Â Â Â Â  else {

Â Â Â Â Â Â Â Â Â Â Â  ## Download the latest version
 Â Â Â Â Â Â Â Â Â Â  return ('{0}?id={1}' -f $psRepositoryUri, $Name.ToLower())
Â Â Â Â Â Â Â  }

    } #end process
} #end function Resolve-AzDoModuleUri.ps1

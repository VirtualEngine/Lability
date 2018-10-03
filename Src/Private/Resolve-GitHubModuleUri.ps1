function Resolve-GitHubModuleUri {
<#
    .SYNOPSIS
        Resolves the correct GitHub URI for the specified Owner, Repository and Branch.
#>
    [CmdletBinding()]
    [OutputType([System.Uri])]
    param (
        ## GitHub repository owner
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Owner,

        ## GitHub repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Repository,

        ## GitHub repository branch
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Branch = 'master',

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    process {

        $uri = 'https://github.com/{0}/{1}/archive/{2}.zip' -f $Owner, $Repository, $Branch;
        return New-Object -TypeName System.Uri -ArgumentList $uri;

    } #end process
} #end function

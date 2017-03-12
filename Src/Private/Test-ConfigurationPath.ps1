function Test-ConfigurationPath  {
<#
    .SYNOPSIS
        Tests the specified path for a computer's .mof file.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Lab vm/node name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## Defined .mof path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [System.String] $Path
    )
    process {

        $searchString = '{0}.*mof' -f $Name;
        $searchPath = Join-Path -Path $Path -ChildPath $searchString;
        Write-Debug -Message ("Searching configuration path '{0}'." -f $searchPath);

        if (Get-ChildItem -Path $searchPath -ErrorAction SilentlyContinue) {

            return $true;
        }

        return $false;

    } #end process
} #end function Test-ConfigurationPath

function InvokeResourceDownload {

<#
    .SYNOPSIS
        Downloads a web resource if it has not already been downloaded or the checksum is incorrect.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Checksum,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {
        [ref] $null = $PSBoundParameters.Remove('Force');
        if (-not (TestResourceDownload @PSBoundParameters) -or $Force) {
            SetResourceDownload @PSBoundParameters -Verbose:$false;
        }
        $resource = GetResourceDownload @PSBoundParameters;
        return [PSCustomObject] $resource;
    } #end process

}


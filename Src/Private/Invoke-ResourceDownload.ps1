function Invoke-ResourceDownload {
<#
    .SYNOPSIS
        Downloads a web resource if it has not already been downloaded or the checksum is incorrect.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Uri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Checksum,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB,

        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
        ##TODO: Support Headers and UserAgent
    )
    process {

        [ref] $null = $PSBoundParameters.Remove('Force');
        if (-not (Test-ResourceDownload @PSBoundParameters) -or $Force) {

            Set-ResourceDownload @PSBoundParameters -Verbose:$false;
            [ref] $null = Test-ResourceDownload @PSBoundParameters -ThrowOnError;
        }
        $resource = Get-ResourceDownload @PSBoundParameters;
        return [PSCustomObject] $resource;

    } #end process
} #end function

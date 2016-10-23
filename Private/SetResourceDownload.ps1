function SetResourceDownload {

<#
    .SYNOPSIS
        Downloads a (web) resource and creates a MD5 checksum.
#>
    [CmdletBinding()]
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
        [System.UInt32] $BufferSize = 64KB,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoChecksum
        ##TODO: Support Headers and UserAgent
    )
    begin {

        $parentDestinationPath = Split-Path -Path $DestinationPath -Parent;
        [ref] $null = NewDirectory -Path $parentDestinationPath;

    }
    process {

        if (-not $PSBoundParameters.ContainsKey('BufferSize')) {
            $systemUri = New-Object -TypeName System.Uri -ArgumentList @($uri);
            if ($systemUri.IsFile) {
                $BufferSize = 1MB;
            }
        }

        WriteVerbose ($localized.DownloadingResource -f $Uri, $DestinationPath);
        InvokeWebClientDownload -DestinationPath $DestinationPath -Uri $Uri -BufferSize $BufferSize;

        if ($NoChecksum -eq $false) {
            ## Create the checksum file for future reference
            [ref] $null = SetResourceChecksum -Path $DestinationPath;
        }

    } #end process

}


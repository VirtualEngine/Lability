function Set-ResourceDownload {
<#
    .SYNOPSIS
        Downloads a (web) resource and creates a MD5 checksum.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Uri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Checksum,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoChecksum,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
        ##TODO: Support Headers and UserAgent
    )
    begin {

        $parentDestinationPath = Split-Path -Path $DestinationPath -Parent;
        [ref] $null = New-Directory -Path $parentDestinationPath;

    }
    process {

        if (-not $PSBoundParameters.ContainsKey('BufferSize')) {

            $systemUri = New-Object -TypeName System.Uri -ArgumentList @($uri);
            if ($systemUri.IsFile) {

                $BufferSize = 1MB;
            }
        }

        Write-Verbose -Message ($localized.DownloadingResource -f $Uri, $DestinationPath);
        Invoke-WebClientDownload -DestinationPath $DestinationPath -Uri $Uri -BufferSize $BufferSize -Credential $FeedCredential;

        if ($NoChecksum -eq $false) {

            ## Create the checksum file for future reference
            [ref] $null = Set-ResourceChecksum -Path $DestinationPath;
        }

    } #end process
} #end function

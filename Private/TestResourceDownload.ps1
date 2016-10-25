function TestResourceDownload {

<#
    .SYNOPSIS
        Tests if a web resource has been downloaded and whether the MD5 checksum is correct.
    .NOTES
        Based upon https://github.com/iainbrighton/cRemoteFile/blob/master/DSCResources/VE_RemoteFile/VE_RemoteFile.ps1
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {

        $resource = GetResourceDownload @PSBoundParameters;
        if ([System.String]::IsNullOrEmpty($Checksum) -and (Test-Path -Path $DestinationPath -PathType Leaf)) {
            WriteVerbose ($localized.ResourceChecksumNotSpecified -f $DestinationPath);
            return $true;
        }
        elseif ($Checksum -eq $resource.Checksum) {
            WriteVerbose ($localized.ResourceChecksumMatch -f $DestinationPath, $Checksum);
            return $true;
        }
        else {
            WriteVerbose ($localized.ResourceChecksumMismatch  -f $DestinationPath, $Checksum);
            return $false;
        }

    } #end process

}


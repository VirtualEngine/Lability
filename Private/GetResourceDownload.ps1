function GetResourceDownload {

<#
    .SYNOPSIS
        Retrieves a downloaded resource's checksum.
    .NOTES
        Based upon https://github.com/iainbrighton/cRemoteFile/blob/master/DSCResources/VE_RemoteFile/VE_RemoteFile.ps1
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
        [System.UInt32] $BufferSize = 64KB
        ##TODO: Support Headers and UserAgent
    )
    process {

        $checksumPath = '{0}.checksum' -f $DestinationPath;
        if (-not (Test-Path -Path $DestinationPath)) {
            WriteVerbose ($localized.MissingResourceFile -f $DestinationPath);
        }
        elseif (-not (Test-Path -Path $checksumPath)) {
            [ref] $null = SetResourceChecksum -Path $DestinationPath;
        }
        if (Test-Path -Path $checksumPath) {
            Write-Debug -Message ('MD5 checksum file ''{0}'' found.' -f $checksumPath);
            $md5Checksum = (Get-Content -Path $checksumPath -Raw).Trim();
            Write-Debug -Message ('Discovered MD5 checksum ''{0}''.' -f $md5Checksum);
        }
        else {
            Write-Debug -Message ('MD5 checksum file ''{0}'' not found.' -f $checksumPath);
        }
        $resource = @{
            DestinationPath = $DestinationPath;
            Uri = $Uri;
            Checksum = $md5Checksum;
        }
        return $resource;

    } #end process

}


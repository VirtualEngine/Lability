function Test-ResourceDownload {
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
        [System.String] $DestinationPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Uri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Checksum,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt32] $BufferSize = 64KB,

        ## Enables mocking terminating calls from Pester
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ThrowOnError

        ##TODO: Support Headers and UserAgent
    )
    process {

        [ref] $null = $PSBoundParameters.Remove('ThrowOnError');
        $resource = Get-ResourceDownload @PSBoundParameters;
        $isCompliant = $true;

        if (-not (Test-Path -Path $DestinationPath -PathType Leaf)) {

            ## If the actual file doesn't exist return a failure! (#205)
            $isCompliant = $false;
        }
        elseif ([System.String]::IsNullOrEmpty($Checksum)) {

            WriteVerbose ($localized.ResourceChecksumNotSpecified -f $DestinationPath);
            $isCompliant = $true;
        }
        elseif ($Checksum -eq $resource.Checksum) {

            WriteVerbose ($localized.ResourceChecksumMatch -f $DestinationPath, $Checksum);
            $isCompliant = $true;
        }
        else {

            WriteVerbose ($localized.ResourceChecksumMismatch  -f $DestinationPath, $Checksum);
            $isCompliant = $false;
        }

        if ($ThrowOnError -and (-not $isCompliant)) {

            throw ($localized.ResourceChecksumMismatchError -f $DestinationPath, $Checksum);
        }
        else {

            return $isCompliant;
        }

    } #end process
} #end function

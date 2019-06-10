function Set-ResourceChecksum {
<#
    .SYNOPSIS
        Creates a resource's checksum file.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Path of file to create the checksum of
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path
    )
    process {

        $checksumPath = '{0}.checksum' -f $Path;
        ## As it can take a long time to calculate the checksum, write it out to disk for future reference
        Write-Verbose -Message ($localized.CalculatingResourceChecksum -f $checksumPath);
        $fileHash = Get-FileHash -Path $Path -Algorithm MD5 -ErrorAction Stop | Select-Object -ExpandProperty Hash;
        Write-Verbose -Message ($localized.WritingResourceChecksum -f $fileHash, $checksumPath);
        $fileHash | Set-Content -Path $checksumPath -Force;

    } #end process
} #end function

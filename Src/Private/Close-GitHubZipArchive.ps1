function Close-GitHubZipArchive {
<#
    .SYNOPSIS
        Tidies up and closes Zip Archive and file handles
#>
    [CmdletBinding()]
    param ()
    process {

        Write-Verbose ($localized.ClosingZipArchive -f $Path);

        if ($null -ne $zipArchive) {

            $zipArchive.Dispose();
        }

        if ($null -ne $fileStream) {

            $fileStream.Close();
        }

    } # end process
} #end function

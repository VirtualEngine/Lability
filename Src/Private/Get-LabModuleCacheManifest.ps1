function Get-LabModuleCacheManifest {
<#
    .SYNOPSIS
        Returns a zipped module's manifest.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## File path to the zipped module
        [Parameter(Mandatory)]
        [System.String] $Path,

        [ValidateSet('PSGallery','GitHub', 'AzDo')]
        [System.String] $Provider = 'PSGallery'
    )
    begin {

        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            throw ($localized.InvalidPathError -f 'Module', $Path);
        }

    }
    process {

        Write-Debug -Message 'Loading ''System.IO.Compression'' .NET binaries.';
        [ref] $null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression");
        [ref] $null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem");

        $moduleFileInfo = Get-Item -Path $Path;

        if ($Provider -in 'PSGallery', 'AzDo') {
            $moduleName = $moduleFileInfo.Name -replace '\.zip', '';
        }elseif ($Provider -eq 'GitHub') {
            ## If we have a GitHub module, trim the _Owner_Branch.zip; if we have a PSGallery module, trim the .zip
            $moduleName = $moduleFileInfo.Name -replace '_\S+_\S+\.zip', '';
        }

        $moduleManifestName = '{0}.psd1' -f $moduleName;
        $temporaryArchivePath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "$moduleName.psd1";

        try {

            ### Open the ZipArchive with read access
            Write-Verbose -Message ($localized.OpeningArchive -f $moduleFileInfo.FullName);
            $archive = New-Object System.IO.Compression.ZipArchive(New-Object System.IO.FileStream($moduleFileInfo.FullName, [System.IO.FileMode]::Open));

            ## Zip archive entries are case-sensitive, therefore, we need to search for a match and can't use ::GetEntry()
            foreach ($archiveEntry in $archive.Entries) {
                if ($archiveEntry.Name -eq $moduleManifestName) {
                    $moduleManifestArchiveEntry = $archiveEntry;
                }
            }

            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($moduleManifestArchiveEntry, $temporaryArchivePath, $true);
            $moduleManifest = ConvertTo-ConfigurationData -ConfigurationData $temporaryArchivePath;
        }

        catch {

            Write-Error ($localized.ReadingArchiveItemError -f $moduleManifestName);
        }
        finally {

            if ($null -ne $archive) {
                Write-Verbose -Message ($localized.ClosingArchive -f $moduleFileInfo.FullName);
                $archive.Dispose();
            }
            Remove-Item -Path $temporaryArchivePath -Force;
        }

        return $moduleManifest;

    } #end process
} #end function

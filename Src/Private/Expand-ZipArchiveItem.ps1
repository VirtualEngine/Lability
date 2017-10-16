function Expand-ZipArchiveItem {
<#
    .SYNOPSIS
        Extracts file(s) from a Zip archive.
    .NOTES
        This is an internal function and should not be called directly.
    .LINK
        This function is derived from the VirtualEngine.Compression (https://github.com/VirtualEngine/Compression) module.
    .OUTPUTS
        A System.IO.FileInfo object for each extracted file.
#>
    [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Reference to Zip archive item.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()] [System.IO.Compression.ZipArchiveEntry[]] [ref] $InputObject,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        # Excludes NuGet .nuspec specific files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ExcludeNuSpecFiles,

        # Overwrite existing physical filesystem files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Write-Debug -Message 'Loading ''System.IO.Compression'' .NET binaries.';
        Add-Type -AssemblyName 'System.IO.Compression';
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem';

    }
    process {

        try {

            [System.Int32] $fileCount = 0;
            $activity = $localized.DecompressingArchive -f $DestinationPath;
            Write-Progress -Activity $activity -PercentComplete 0;
            foreach ($zipArchiveEntry in $InputObject) {

                $fileCount++;
                if (($fileCount % 5) -eq 0) {

                    [System.Int16] $percentComplete = ($fileCount / $InputObject.Count) * 100
                    $status = $localized.CopyingResourceStatus -f $fileCount, $InputObject.Count, $percentComplete;
                    Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete;
                }

                ## Exclude the .nuspec specific files
                if ($ExcludeNuSpecFiles -and ($zipArchiveEntry.FullName -match '(_rels\/)|(\[Content_Types\]\.xml)|(\w+\.nuspec)')) {
                    Write-Verbose -Message ($localized.IgnoringNuspecZipArchiveEntry -f $zipArchiveEntry.FullName);
                    continue;
                }

                if ($zipArchiveEntry.FullName.Contains('/')) {

                    ## We need to create the directory path as the ExtractToFile extension method won't do this and will throw an exception
                    $pathSplit = $zipArchiveEntry.FullName.Split('/');
                    $relativeDirectoryPath = New-Object -TypeName System.Text.StringBuilder;

                    ## Generate the relative directory name
                    for ($pathSplitPart = 0; $pathSplitPart -lt ($pathSplit.Count -1); $pathSplitPart++) {

                        [ref] $null = $relativeDirectoryPath.AppendFormat('{0}\', $pathSplit[$pathSplitPart]);
                    }
                    $relativePath = $relativeDirectoryPath.ToString();

                    ## Create the destination directory path, joining the relative directory name
                    $directoryPath = Join-Path -Path $DestinationPath -ChildPath $relativePath;
                    [ref] $null = New-Directory -Path $directoryPath;

                    $fullDestinationFilePath = Join-Path -Path $directoryPath -ChildPath $zipArchiveEntry.Name;
                } # end if
                else {

                    ## Just a file in the root so just use the $DestinationPath
                    $fullDestinationFilePath = Join-Path -Path $DestinationPath -ChildPath $zipArchiveEntry.Name;
                } # end else

                if ([System.String]::IsNullOrEmpty($zipArchiveEntry.Name)) {

                    ## This is a folder and we need to create the directory path as the
                    ## ExtractToFile extension method won't do this and will throw an exception
                    $pathSplit = $zipArchiveEntry.FullName.Split('/');
                    $relativeDirectoryPath = New-Object -TypeName System.Text.StringBuilder;

                    ## Generate the relative directory name
                    for ($pathSplitPart = 0; $pathSplitPart -lt ($pathSplit.Count -1); $pathSplitPart++) {
                        [ref] $null = $relativeDirectoryPath.AppendFormat('{0}\', $pathSplit[$pathSplitPart]);
                    }
                    $relativePath = $relativeDirectoryPath.ToString();

                    ## Create the destination directory path, joining the relative directory name
                    $directoryPath = Join-Path -Path $DestinationPath -ChildPath $relativePath;
                    [ref] $null = New-Directory -Path $directoryPath;

                    $fullDestinationFilePath = Join-Path -Path $directoryPath -ChildPath $zipArchiveEntry.Name;
                }
                elseif (-not $Force -and (Test-Path -Path $fullDestinationFilePath -PathType Leaf)) {

                    ## Are we overwriting existing files (-Force)?
                    Write-Warning -Message ($localized.TargetFileExistsWarning -f $fullDestinationFilePath);
                }
                else {

                    ## Just overwrite any existing file
                    if ($Force -or $PSCmdlet.ShouldProcess($fullDestinationFilePath, 'Expand')) {
                        Write-Verbose -Message ($localized.ExtractingZipArchiveEntry -f $fullDestinationFilePath);
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($zipArchiveEntry, $fullDestinationFilePath, $true);
                        ## Return a FileInfo object to the pipline
                        Write-Output -InputObject (Get-Item -Path $fullDestinationFilePath);
                    }
                } # end if

            } # end foreach zipArchiveEntry

            Write-Progress -Activity $activity -Completed;

        } # end try
        catch {

            Write-Error -Message $_.Exception;
        }

    } # end process
} #end function

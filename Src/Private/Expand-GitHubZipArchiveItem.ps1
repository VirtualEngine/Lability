function Expand-GitHubZipArchiveItem {
<#
    .SYNOPSIS
        Extracts file(s) from a GitHub Zip archive.
    .NOTES
        This is an internal function and should not be called directly.
    .LINK
        This function is derived from the VirtualEngine.Compression (https://github.com/VirtualEngine/Compression) module.
    .OUTPUTS
        A System.IO.FileInfo object for each extracted file.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Reference to Zip archive item.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'InputObject')]
        [System.IO.Compression.ZipArchiveEntry[]] [ref] $InputObject,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [System.String] $DestinationPath,

        # GitHub repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Repository,

        ## Override repository name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OverrideRepository,

        # Overwrite existing physical filesystem files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Write-Debug 'Loading ''System.IO.Compression'' .NET binaries.';
        Add-Type -AssemblyName 'System.IO.Compression';
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem';

    }
    process {

        try {

            ## Regex for locating the <RepositoryName>-<Branch>\ root directory
            $searchString = '^{0}-\S+?\\' -f $Repository;
            $replacementString = '{0}\' -f $Repository;
            if ($OverrideRepository) {

                $replacementString = '{0}\' -f $OverrideRepository;
            }

            [System.Int32] $fileCount = 0;
            $moduleDestinationPath = Join-Path -Path $DestinationPath -ChildPath $Repository;
            $activity = $localized.DecompressingArchive -f $moduleDestinationPath;
            Write-Progress -Activity $activity -PercentComplete 0;

            foreach ($zipArchiveEntry in $InputObject) {

                $fileCount++;
                if (($fileCount % 5) -eq 0) {

                    [System.Int16] $percentComplete = ($fileCount / $InputObject.Count) * 100
                    $status = $localized.CopyingResourceStatus -f $fileCount, $InputObject.Count, $percentComplete;
                    Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete;
                }

                if ($zipArchiveEntry.FullName.Contains('/')) {

                    ## We need to create the directory path as the ExtractToFile extension method won't do this and will throw an exception
                    $pathSplit = $zipArchiveEntry.FullName.Split('/');
                    $relativeDirectoryPath = New-Object System.Text.StringBuilder;

                    ## Generate the relative directory name
                    for ($pathSplitPart = 0; $pathSplitPart -lt ($pathSplit.Count -1); $pathSplitPart++) {
                        [ref] $null = $relativeDirectoryPath.AppendFormat('{0}\', $pathSplit[$pathSplitPart]);
                    }
                    ## Rename the GitHub \<RepositoryName>-<Branch>\ root directory to \<RepositoryName>\
                    $relativePath = ($relativeDirectoryPath.ToString() -replace $searchString, $replacementString).TrimEnd('\');

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
                    $relativeDirectoryPath = New-Object System.Text.StringBuilder;

                    ## Generate the relative directory name
                    for ($pathSplitPart = 0; $pathSplitPart -lt ($pathSplit.Count -1); $pathSplitPart++) {

                        [ref] $null = $relativeDirectoryPath.AppendFormat('{0}\', $pathSplit[$pathSplitPart]);
                    }

                    ## Rename the GitHub \<RepositoryName>-<Branch>\ root directory to \<RepositoryName>\
                    $relativePath = ($relativeDirectoryPath.ToString() -replace $searchString, $replacementString).TrimEnd('\');

                    ## Create the destination directory path, joining the relative directory name
                    $directoryPath = Join-Path -Path $DestinationPath -ChildPath $relativePath;
                    [ref] $null = New-Directory -Path $directoryPath;

                    $fullDestinationFilePath = Join-Path -Path $directoryPath -ChildPath $zipArchiveEntry.Name;
                }
                elseif (-not $Force -and (Test-Path -Path $fullDestinationFilePath -PathType Leaf)) {

                    ## Are we overwriting existing files (-Force)?
                    Write-Warning ($localized.TargetFileExistsWarning -f $fullDestinationFilePath);
                }
                else {

                    ## Just overwrite any existing file
                    if ($Force -or $PSCmdlet.ShouldProcess($fullDestinationFilePath, 'Expand')) {

                        Write-Debug ($localized.ExtractingZipArchiveEntry -f $fullDestinationFilePath);
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($zipArchiveEntry, $fullDestinationFilePath, $true);
                        ## Return a FileInfo object to the pipline
                        Write-Output (Get-Item -Path $fullDestinationFilePath);
                    }
                } # end if
            } # end foreach zipArchiveEntry

            Write-Progress -Activity $activity -Completed;

        } # end try
        catch {

            Write-Error $_.Exception;
        }

    } # end process
} #end function

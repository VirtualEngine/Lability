function ExpandZipArchive {
<#
    .SYNOPSIS
        Extracts a GitHub Zip archive.
    .NOTES
        This is an internal function and should not be called directly.
    .LINK
        This function is derived from the VirtualEngine.Compression (https://github.com/VirtualEngine/Compression) module.
    .OUTPUTS
        A System.IO.FileInfo object for each extracted file.
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        # Source path to the Zip Archive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)] [ValidateNotNullOrEmpty()]
        [Alias('PSPath','FullName')] [System.String[]] $Path,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        # Excludes NuGet .nuspec specific files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ExcludeNuSpecFiles,

        # Overwrite existing files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {
        ## Validate destination path
        if (-not (Test-Path -Path $DestinationPath -IsValid)) {
            throw ($localized.InvalidDestinationPathError -f $DestinationPath);
        }
        $DestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath);
        WriteVerbose -Message ($localized.ResolvedDestinationPath -f $DestinationPath);
        [ref] $null = NewDirectory -Path $DestinationPath;
        foreach ($pathItem in $Path) {
            foreach ($resolvedPath in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($pathItem)) {
                WriteVerbose -Message ($localized.ResolvedSourcePath -f $resolvedPath);
                $LiteralPath += $resolvedPath;
            }
        }
        ## If all tests passed, load the required .NET assemblies
        Write-Debug -Message 'Loading ''System.IO.Compression'' .NET binaries.';
        Add-Type -AssemblyName 'System.IO.Compression';
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem';
    } # end begin
    process {
        foreach ($pathEntry in $LiteralPath) {
            try {
                $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($pathEntry);
                $expandZipArchiveItemParams = @{
                    InputObject = [ref] $zipArchive.Entries;
                    DestinationPath = $DestinationPath;
                    ExcludeNuSpecFiles = $ExcludeNuSpecFiles;
                    Force = $Force;
                }
                ExpandZipArchiveItem @expandZipArchiveItemParams;
            } # end try
            catch {
                Write-Error -Message $_.Exception;
            }
            finally {
                ## Close the file handle
                CloseZipArchive;
            }
        } # end foreach
    } # end process
} #end function ExpandZipArchive

function ExpandZipArchiveItem {
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
    [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Reference to Zip archive item.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()] [System.IO.Compression.ZipArchiveEntry[]] [ref] $InputObject,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)] [ValidateNotNullOrEmpty()]
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
                    WriteVerbose -Message ($localized.IgnoringNuspecZipArchiveEntry -f $zipArchiveEntry.FullName);
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
                    [ref] $null = NewDirectory -Path $directoryPath;

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
                    [ref] $null = NewDirectory -Path $directoryPath;

                    $fullDestinationFilePath = Join-Path -Path $directoryPath -ChildPath $zipArchiveEntry.Name;
                }
                elseif (-not $Force -and (Test-Path -Path $fullDestinationFilePath -PathType Leaf)) {
                    ## Are we overwriting existing files (-Force)?
                    WriteWarning -Message ($localized.TargetFileExistsWarning -f $fullDestinationFilePath);
                }
                else {
                    ## Just overwrite any existing file
                    if ($Force -or $PSCmdlet.ShouldProcess($fullDestinationFilePath, 'Expand')) {
                        WriteVerbose -Message ($localized.ExtractingZipArchiveEntry -f $fullDestinationFilePath);
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
} #end function ExpandZipArchiveItem

function CloseZipArchive {
<#
    .SYNOPSIS
        Tidies up and closes Zip Archive and file handles
#>
    [CmdletBinding()]
    param ()
    process {
        WriteVerbose -Message ($localized.ClosingZipArchive -f $Path);
        if ($zipArchive -ne $null) {
            $zipArchive.Dispose();
        }
        if ($null -ne $fileStream) {
            $fileStream.Close();
        }
    } # end process
} #end function CloseZipArchive

function ExpandGitHubZipArchive {
<#
    .SYNOPSIS
        Extracts a GitHub Zip archive.
    .NOTES
        This is an internal function and should not be called directly.
    .LINK
        This function is derived from the GitHubRepository (https://github.com/IainBrighton/GitHubRepositoryCompression) module.
    .OUTPUTS
        A System.IO.FileInfo object for each extracted file.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Source path to the Zip Archive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath','FullName')] [System.String[]] $Path,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        # GitHub repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Repository,

        # GitHub repository branch name
        [Parameter(ValueFromPipelineByPropertyName, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch = 'master',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OverrideRepository,

        # Overwrite existing files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Remove root folders/files in archive from destination path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Clean
    )
    begin {

        ## Validate destination path
        if (-not (Test-Path -Path $DestinationPath -IsValid)) {
            throw ($localized.InvalidDestinationPathError -f $DestinationPath);
        }

        $DestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath);
        WriteVerbose ($localized.ResolvedDestinationPath -f $DestinationPath);
        [Ref] $null = NewDirectory -Path $DestinationPath;

        foreach ($pathItem in $Path) {

            foreach ($resolvedPath in $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($pathItem)) {
                WriteVerbose ($localized.ResolvedSourcePath -f $resolvedPath);
                $LiteralPath += $resolvedPath;
            }
        }

        ## If all tests passed, load the required .NET assemblies
        Write-Debug 'Loading ''System.IO.Compression'' .NET binaries.';
        Add-Type -AssemblyName 'System.IO.Compression';
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem';

    } # end begin
    process {

        if ($Clean) {
            ## Remove repository directory before expanding any items..
            $repositoryPath = Join-Path -Path $DestinationPath -ChildPath $Repository;
            if ($OverrideRepository) {
                $repositoryPath = Join-Path -Path $DestinationPath -ChildPath $OverrideRepository;
            }
            WriteVerbose ($localized.CleaningModuleDirectory -f $repositoryPath);
            if (Test-Path -Path $repositoryPath -PathType Container) {
                Remove-Item -Path $repositoryPath -Force -Recurse -ErrorAction Stop;
            }
        }

        foreach ($pathEntry in $LiteralPath) {

            try {

                $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($pathEntry);
                $expandZipArchiveItemParams = @{
                    InputObject = [ref] $zipArchive.Entries;
                    DestinationPath = $DestinationPath;
                    Repository = $Repository;
                    Branch = $Branch;
                    Force = $Force;
                }

                if ($OverrideRepository) {
                    $expandZipArchiveItemParams['OverrideRepository'] = $OverrideRepository;
                }

                ExpandGitHubZipArchiveItem @expandZipArchiveItemParams;

            } # end try
            catch {
                Write-Error $_.Exception;
            }
            finally {
                ## Close the file handle
                CloseGitHubZipArchive;
            }

        } # end foreach

    } # end process
} #end function ExpandGitHubZipArchive


function ExpandGitHubZipArchiveItem {
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
    [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Reference to Zip archive item.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()]
        [System.IO.Compression.ZipArchiveEntry[]] [Ref] $InputObject,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        # GitHub repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Repository,

        # GitHub repository branch name
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch = 'master',

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
            $searchString = '^{0}-{1}\\' -f $Repository, $Branch;
            $replacementString = '{0}\' -f $Repository;
            if ($OverrideRepository) {
                $replacementString = '{0}\' -f $OverrideRepository;
            }

            foreach ($zipArchiveEntry in $InputObject) {

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
                    $relativeDirectoryPath = New-Object System.Text.StringBuilder;

                    ## Generate the relative directory name
                    for ($pathSplitPart = 0; $pathSplitPart -lt ($pathSplit.Count -1); $pathSplitPart++) {
                        [ref] $null = $relativeDirectoryPath.AppendFormat('{0}\', $pathSplit[$pathSplitPart]);
                    }

                    ## Rename the GitHub \<RepositoryName>-<Branch>\ root directory to \<RepositoryName>\
                    $relativePath = ($relativeDirectoryPath.ToString() -replace $searchString, $replacementString).TrimEnd('\');

                    ## Create the destination directory path, joining the relative directory name
                    $directoryPath = Join-Path -Path $DestinationPath -ChildPath $relativePath;
                    [ref] $null = NewDirectory -Path $directoryPath;

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
        } # end try
        catch {
            Write-Error $_.Exception;
        }

    } # end process
} #end function ExpandGitHubZipArchiveItem


function CloseGitHubZipArchive {
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
} #end function CloseGitHubZipArchive

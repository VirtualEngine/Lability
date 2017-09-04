function Expand-GitHubZipArchive {
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
        [Alias('PSPath','FullName')]
        [System.String[]] $Path,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [System.String] $DestinationPath,

        # GitHub repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Repository,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OverrideRepository,

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
        WriteVerbose ($localized.ResolvedDestinationPath -f $DestinationPath);
        [ref] $null = New-Directory -Path $DestinationPath;

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

        foreach ($pathEntry in $LiteralPath) {

            try {

                $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($pathEntry);
                $expandZipArchiveItemParams = @{
                    InputObject = [ref] $zipArchive.Entries;
                    DestinationPath = $DestinationPath;
                    Repository = $Repository;
                    Force = $Force;
                }

                if ($OverrideRepository) {
                    $expandZipArchiveItemParams['OverrideRepository'] = $OverrideRepository;
                }

                Expand-GitHubZipArchiveItem @expandZipArchiveItemParams;

            } # end try
            catch {

                Write-Error $_.Exception;
            }
            finally {

                ## Close the file handle
                Close-GitHubZipArchive;
            }

        } # end foreach

    } # end process
} #end function

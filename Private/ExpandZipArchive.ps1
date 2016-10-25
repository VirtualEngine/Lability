function ExpandZipArchive {

<#
    .SYNOPSIS
        Extracts a Zip archive.
    .NOTES
        This is an internal function and should not be called directly.
    .LINK
        This function is derived from the VirtualEngine.Compression (https://github.com/VirtualEngine/Compression) module.
    .OUTPUTS
        A System.IO.FileInfo object for each extracted file.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        # Source path to the Zip Archive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath','FullName')] [System.String[]] $Path,

        # Destination file path to extract the Zip Archive item to.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
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

}


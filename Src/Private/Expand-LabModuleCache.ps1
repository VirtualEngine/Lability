function Expand-LabModuleCache {
<#
    .SYNOPSIS
        Extracts a cached PowerShell module to the specified destination module path.
#>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        ## PowerShell module hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable[]] $Module,

        ## Destination directory path to download the PowerShell module/DSC resource module to
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DestinationPath,

        ## Removes existing module directory if present
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Clean,

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    begin {

        [ref] $null = $PSBoundParameters.Remove('RemainingArguments');

    }
    process {

        foreach ($moduleInfo in $Module) {

            $moduleFileInfo = Get-LabModuleCache @moduleInfo;
            $moduleSourcePath = $moduleFileInfo.FullName;
            $moduleDestinationPath = Join-Path -Path $DestinationPath -ChildPath $moduleInfo.Name;

            if ($Clean -and (Test-Path -Path $moduleDestinationPath -PathType Container)) {
                Write-Verbose -Message ($localized.CleaningModuleDirectory -f $moduleDestinationPath);
                Remove-Item -Path $moduleDestinationPath -Recurse -Force -Confirm:$false;
            }

            if ((-not $moduleInfo.ContainsKey('Provider')) -or
                    ($moduleInfo.Provider -in 'PSGallery', 'AzDo')) {

                Write-Verbose -Message ($localized.ExpandingModule -f $moduleDestinationPath);
                $expandZipArchiveParams = @{
                    Path = $moduleSourcePath;
                    DestinationPath = $moduleDestinationPath;
                    ExcludeNuSpecFiles = $true;
                    Force = $true;
                    Verbose = $false;
                    WarningAction = 'SilentlyContinue';
                    Confirm = $false;
                }
                [ref] $null = Expand-ZipArchive @expandZipArchiveParams;

            } #end if PSGallery or Azdo
            elseif (($moduleInfo.ContainsKey('Provider')) -and
                    ($moduleInfo.Provider -eq 'GitHub')) {

                Write-Verbose -Message ($localized.ExpandingModule -f $moduleDestinationPath);
                $expandGitHubZipArchiveParams = @{
                    Path = $moduleSourcePath;
                    ## GitHub modules include the module directory. Therefore, we need the parent root directory
                    DestinationPath = Split-Path -Path $moduleDestinationPath -Parent;;
                    Repository = $moduleInfo.Name;
                    Force = $true;
                    Verbose = $false;
                    WarningAction = 'SilentlyContinue';
                    Confirm = $false;
                }

                if ($moduleInfo.ContainsKey('OverrideRepository')) {
                    $expandGitHubZipArchiveParams['OverrideRepository'] = $moduleInfo.OverrideRepository;
                }

                [ref] $null = Expand-GitHubZipArchive @expandGitHubZipArchiveParams;

            } #end if GitHub
            elseif (($moduleInfo.ContainsKey('Provider')) -and
                    ($moduleInfo.Provider -eq 'FileSystem')) {
                if ($null -ne $moduleFileInfo) {

                    if ($moduleFileInfo -is [System.IO.FileInfo]) {

                        Write-Verbose -Message ($localized.ExpandingModule -f $moduleDestinationPath);
                        $expandZipArchiveParams = @{
                            Path = $moduleSourcePath;
                            DestinationPath = $moduleDestinationPath;
                            ExcludeNuSpecFiles = $true;
                            Force = $true;
                            Verbose = $false;
                            WarningAction = 'SilentlyContinue';
                            Confirm = $false;
                        }
                        [ref] $null = Expand-ZipArchive @expandZipArchiveParams;
                    }
                    elseif ($moduleFileInfo -is [System.IO.DirectoryInfo]) {

                        Write-Verbose -Message ($localized.CopyingModuleDirectory -f $moduleFileInfo.Name, $moduleDestinationPath);
                        ## If the target doesn't exist create it. We may be copying a versioned
                        ## module, i.e. \xJea\0.2.16.6 to \xJea..
                        if (-not (Test-Path -Path $moduleDestinationPath -PathType Container)) {
                            New-Item -Path $moduleDestinationPath -ItemType Directory -Force;
                        }
                        $copyItemParams = @{
                            Path = "$moduleSourcePath\*";
                            Destination = $moduleDestinationPath;
                            Recurse = $true;
                            Force = $true;
                            Verbose = $false;
                            Confirm = $false;
                        }
                        Copy-Item @copyItemParams;
                    }

                }
            } #end if FileSystem

            ## Only output if we found a module during this pass
            if ($null -ne $moduleFileInfo) {
                Write-Output -InputObject (Get-Item -Path $moduleDestinationPath);
            }

        } #end foreach module

    } #end process
} #end function

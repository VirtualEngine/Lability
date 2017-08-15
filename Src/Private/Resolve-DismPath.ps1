function Resolve-DismPath {
<#
    .SYNOPSIS
        Resolves the specified path to a path to DISM dll.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Path
    )
    process {

        if (-not (Test-Path -Path $Path)) {

            ## Path doesn't exist
            throw ($localized.InvalidPathError -f 'Directory', $DismPath);
        }
        else {

            $dismItem = Get-Item -Path $Path;
            $dismDllName = 'Microsoft.Dism.Powershell.dll';

            if ($dismItem.Name -ne $dismDllName) {

                if ($dismItem -is [System.IO.DirectoryInfo]) {

                    $dismItemPath = Join-Path -Path $DismPath -ChildPath $dismDllName;

                    if (-not (Test-Path -Path $dismItemPath)) {

                        throw ($localized.CannotLocateDismDllError -f $Path);
                    }
                    else {

                        $dismItem = Get-Item -Path $dismItemPath;
                    }
                }
                else {

                    throw ($localized.InvalidPathError -f 'File', $DismPath);
                }

            }
        }

        return $dismItem.FullName;

    } #end process
} #end function

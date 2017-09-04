function Resolve-PathEx {
<#
    .SYNOPSIS
        Resolves the wildcard characters in a path, and displays the path contents, ignoring non-existent paths.
    .DESCRIPTION
        The Resolve-Path cmdlet interprets the wildcard characters in a path and displays the items and containers at
        the location specified by the path, such as the files and folders or registry keys and subkeys.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)]
        [System.String] $Path
    )
    process {

        try {

            $expandedPath = [System.Environment]::ExpandEnvironmentVariables($Path);
            $resolvedPath = Resolve-Path -Path $expandedPath -ErrorAction Stop;
            $Path = $resolvedPath.ProviderPath;
        }
        catch [System.Management.Automation.ItemNotFoundException] {

            $Path = [System.Environment]::ExpandEnvironmentVariables($_.TargetObject);
            $Error.Remove($Error[-1]);
        }

        return $Path;

    } #end process
} #end function

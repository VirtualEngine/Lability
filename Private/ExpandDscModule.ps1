function ExpandDscModule {

<#
    .SYNOPSIS
        Extracts a DSC resource .zip archive using Windows Explorer and removes -master or -dev directory suffixes.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $ModuleName,
        
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        [Parameter(Mandatory)]
        [System.String] $DestinationPath,
        
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        $targetPath = Join-Path -Path $DestinationPath -ChildPath $ModuleName;
        if (-not (Test-Path -Path $targetPath) -or $Force) {
            if (Test-Path -Path $targetPath) {
                WriteVerbose ($localized.RemovingDirectory -f $targetPath);
                Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop;
            }
            WriteVerbose ($localized.ExpandingArchive -f $Path, $DestinationPath);
            $shellApplication = New-Object -ComObject Shell.Application;
            $archiveItems = $shellApplication.Namespace($Path).Items();
            $shellApplication.NameSpace($DestinationPath).CopyHere($archiveItems);
            ## Rename any -master branch folder where no GitHub release available
            Get-ChildItem -Path $DestinationPath -Directory | Where-Object { $_.Name -like '*-dev' -or $_.Name -like '*-master' } | ForEach-Object {
                $destinationFilename = $_.Name -replace '-dev','' -replace '-master','';
                WriteVerbose ($localized.RenamingPath -f $_.FullName, $destinationFilename);
                Rename-Item -Path $_.FullName -NewName $destinationFilename -ErrorAction Stop;
            }
        }
    } #end process

}


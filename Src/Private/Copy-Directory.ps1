function CopyDirectory {
<#
    .SYNOPSIS
        Copies a directory structure with progress.
#>
    [CmdletBinding()]
    param (
        ## Source directory path
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.IO.DirectoryInfo] $SourcePath,

        ## Destination directory path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.IO.DirectoryInfo] $DestinationPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        if ((Get-Item $SourcePath) -isnot [System.IO.DirectoryInfo]) {

            throw ($localized.CannotProcessArguentError -f 'CopyDirectory', 'SourcePath', $SourcePath, 'System.IO.DirectoryInfo');
        }
        elseif (Test-Path -Path $SourcePath -PathType Leaf) {

            throw ($localized.InvalidDestinationPathError -f $DestinationPath);
        }

    }
    process {

        $activity = $localized.CopyingResource -f $SourcePath.FullName, $DestinationPath;
        $status = $localized.EnumeratingPath -f $SourcePath;
        Write-Progress -Activity $activity -Status $status -PercentComplete 0;
        $fileList = Get-ChildItem -Path $SourcePath -File -Recurse;
        $currentDestinationPath = $SourcePath;

        for ($i = 0; $i -lt $fileList.Count; $i++) {

            if ($currentDestinationPath -ne $fileList[$i].DirectoryName) {

                ## We have a change of directory
                $destinationDirectoryName = $fileList[$i].DirectoryName.Substring($SourcePath.FullName.Trim('\').Length);
                $destinationDirectoryPath = Join-Path -Path $DestinationPath -ChildPath $destinationDirectoryName;
                [ref] $null = New-Item -Path $destinationDirectoryPath -ItemType Directory -ErrorAction Ignore;
                $currentDestinationPath = $fileList[$i].DirectoryName;
            }

            if (($i % 5) -eq 0) {

                [System.Int16] $percentComplete = (($i + 1) / $fileList.Count) * 100;
                $status = $localized.CopyingResourceStatus -f $i, $fileList.Count, $percentComplete;
                Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete;
            }

            $targetPath = Join-Path -Path $DestinationPath -ChildPath $fileList[$i].FullName.Replace($SourcePath, '');
            Copy-Item -Path $fileList[$i].FullName -Destination $targetPath -Force:$Force;
        } #end for

        Write-Progress -Activity $activity -Completed;

    } #end process
} #end function

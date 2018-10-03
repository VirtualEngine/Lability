function Expand-LabIso {
<#
    .SYNOPSIS
        Expands an ISO disk image resource
#>
    param (
        ## Source ISO file path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## Destination folder path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DestinationPath
    )
    process {

        Write-Verbose -Message ($localized.MountingDiskImage -f $Path);
        $iso = Mount-DiskImage -ImagePath $Path -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
        ## Refresh drives
        [ref] $null = Get-PSDrive;
        $isoDriveLetter = $iso | Get-Volume | Select-Object -ExpandProperty DriveLetter;
        $sourcePath = '{0}:\' -f $isoDriveLetter;
        Write-Verbose -Message ($localized.ExpandingIsoResource -f $DestinationPath);
        CopyDirectory -SourcePath $sourcePath -DestinationPath $DestinationPath -Force -Verbose:$false;
        Write-Verbose -Message ($localized.DismountingDiskImage -f $Path);
        Dismount-DiskImage -ImagePath $Path;

    } #end process
} #end function

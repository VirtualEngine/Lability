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

        ## Disable BitLocker fixed drive write protection if enabled
        $FDVDenyWriteAccess = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess').FDVDenyWriteAccess;
        if ($FDVDenyWriteAccess) {

            Write-Verbose -Message $localized.DisablingBitlockerWriteProtection
            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value 0;
        }

        Write-Verbose -Message ($localized.MountingDiskImage -f $Path);
        $iso = Storage\Mount-DiskImage -ImagePath $Path -StorageType ISO -Access ReadOnly -PassThru -Verbose:$false;
        ## Refresh drives
        [ref] $null = Get-PSDrive;
        $isoDriveLetter = $iso | Storage\Get-Volume | Select-Object -ExpandProperty DriveLetter;
        $sourcePath = '{0}:\' -f $isoDriveLetter;
        Write-Verbose -Message ($localized.ExpandingIsoResource -f $DestinationPath);
        CopyDirectory -SourcePath $sourcePath -DestinationPath $DestinationPath -Force -Verbose:$false;
        Write-Verbose -Message ($localized.DismountingDiskImage -f $Path);
        Storage\Dismount-DiskImage -ImagePath $Path;

        if ($FDVDenyWriteAccess) {

            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value $FDVDenyWriteAccess;
        }

    } #end process
} #end function

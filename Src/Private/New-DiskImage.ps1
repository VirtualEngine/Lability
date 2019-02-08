function New-DiskImage {
<#
    .SYNOPSIS
        Create a new formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## VHD/x file path
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Disk image size in bytes
        [Parameter()]
        [System.UInt64] $Size = 127GB,

        ## Disk image size in bytes
        [Parameter()]
        [ValidateSet('Dynamic','Fixed')]
        [System.String] $Type = 'Dynamic',

        ## Overwrite/recreate existing disk image
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Do not dismount the VHD/x and return a reference
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Passthru
    )
    begin {

        if ((Test-Path -Path $Path -PathType Leaf) -and (-not $Force)) {

            throw ($localized.ImageAlreadyExistsError -f $Path);
        }
        elseif ((Test-Path -Path $Path -PathType Leaf) -and ($Force)) {

            Hyper-V\Dismount-VHD -Path $Path -ErrorAction Stop;
            Write-Verbose -Message ($localized.RemovingDiskImage -f $Path);
            Remove-Item -Path $Path -Force -ErrorAction Stop;
        }

    } #end begin
    process {

        $newVhdParams = @{
            Path = $Path;
            SizeBytes = $Size;
            $Type = $true;
        }

        Write-Verbose -Message ($localized.CreatingDiskImageType -f $Type.ToLower(), $Path, ($Size/1MB));
        [ref] $null = Hyper-V\New-Vhd @newVhdParams;

        ## Disable BitLocker fixed drive write protection if enabled
        $FDVDenyWriteAccess = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess').FDVDenyWriteAccess;
        if ($FDVDenyWriteAccess) {

            Write-Verbose -Message $localized.DisablingBitlockerWriteProtection
            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value 0;
        }

        Write-Verbose -Message ($localized.MountingDiskImage -f $Path);
        $vhdMount = Hyper-V\Mount-VHD -Path $Path -Passthru;

        Write-Verbose -Message ($localized.InitializingDiskImage -f $Path);
        [ref] $null = Storage\Initialize-Disk -Number $vhdMount.DiskNumber -PartitionStyle $PartitionStyle -PassThru;

        switch ($PartitionStyle) {
            'MBR' {
                New-DiskImageMbr -Vhd $vhdMount;
            }
            'GPT' {
                New-DiskImageGpt -Vhd $vhdMount;
            }
        }

        if ($Passthru) {

            return $vhdMount;
        }
        else {

            Hyper-V\Dismount-VHD -Path $Path;
        }

        if ($FDVDenyWriteAccess) {

            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FVE' -Name 'FDVDenyWriteAccess' -Value $FDVDenyWriteAccess;
        }

    } #end process
} #end function

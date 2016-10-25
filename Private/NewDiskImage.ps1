function NewDiskImage {

<#
    .SYNOPSIS
        Create a new formatted disk image.
#>
    [CmdletBinding()]
    param (
        ## VHD/x file path
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Disk image partition scheme
        [Parameter(Mandatory)]
        [ValidateSet('MBR','GPT')]
        [System.String] $PartitionStyle,

        ## Disk image size in bytes
        [Parameter()]
        [System.UInt64] $Size = 127GB,

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

            Dismount-VHD -Path $Path -ErrorAction Stop;
            WriteVerbose ($localized.RemovingDiskImage -f $Path);
            Remove-Item -Path $Path -Force -ErrorAction Stop;
        }

    } #end begin
    process {

        WriteVerbose ($localized.CreatingDiskImage -f $Path);
        $vhd = New-Vhd -Path $Path -Dynamic -SizeBytes $Size;
        WriteVerbose ($localized.MountingDiskImage -f $Path);
        $vhdMount = Mount-VHD -Path $Path -Passthru;
        WriteVerbose ($localized.InitializingDiskImage -f $Path);
        [ref] $null = Initialize-Disk -Number $vhdMount.DiskNumber -PartitionStyle $PartitionStyle -PassThru;

        switch ($PartitionStyle) {
            'MBR' {
                NewDiskImageMbr -Vhd $vhdMount;
            }
            'GPT' {
                NewDiskImageGpt -Vhd $vhdMount;
            }
        }

        if ($Passthru) {

            return $vhdMount;
        }
        else {

            Dismount-VHD -Path $Path;
        }

    } #end process

}


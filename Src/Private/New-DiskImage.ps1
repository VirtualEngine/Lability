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

            Dismount-VHD -Path $Path -ErrorAction Stop;
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
        [ref] $null = New-Vhd @newVhdParams;

        Write-Verbose -Message ($localized.MountingDiskImage -f $Path);
        $vhdMount = Mount-VHD -Path $Path -Passthru;

        Write-Verbose -Message ($localized.InitializingDiskImage -f $Path);
        [ref] $null = Initialize-Disk -Number $vhdMount.DiskNumber -PartitionStyle $PartitionStyle -PassThru;

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

            Dismount-VHD -Path $Path;
        }

    } #end process
} #end function

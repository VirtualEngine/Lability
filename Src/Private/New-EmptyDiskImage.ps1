function New-EmptyDiskImage {
<#
    .SYNOPSIS
        Create an empty disk image.
#>
    [CmdletBinding()]
    param (
        ## VHD/x file path
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Disk image size in bytes
        [Parameter()]
        [System.UInt64] $Size = 127GB,

        ## Disk image size in bytes
        [Parameter()]
        [ValidateSet('Dynamic','Fixed')]
        [System.String] $Type = 'Dynamic',

        ## Overwrite/recreate existing disk image
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Force
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

    } #end process
} #end function

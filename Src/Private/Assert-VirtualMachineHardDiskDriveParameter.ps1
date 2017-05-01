function Assert-VirtualMachineHardDiskDriveParameter {
<#
    .SYNOPSIS
        Ensures parameters specified in the Lability_HardDiskDrive hashtable are correct.
#>
    [CmdletBinding()]
    param (
        ## Virtual hard disk type
        [Parameter()]
        [System.String] $Type,

        ## Dynamic Vhd size. Minimum 3MB and maximum 2,040GB
        [Parameter()]
        [System.UInt64] $MaximumSizeBytes,

        [Parameter()]
        [System.String] $VhdPath,

        [Parameter()]
        [System.UInt32] $VMGeneration
    )
    process {

        if ($PSBoundParameters.ContainsKey('VhdPath')) {

            if (($PSBoundParameters.Keys -contains 'Type') -or
                ($PSBoundParameters.Keys -contains 'MaximumSizeBytes')) {

                throw ($localized.CannotResoleVhdParameterError);
            }

            if (-not (Test-Path -Path $VhdPath -PathType Leaf)) {

                throw ($localized.CannotLocateVhdError -f $VhdPath);
            }
        }
        elseif ($PSBoundParameters.ContainsKey('Type')) {

            ## A Generation 2 virtual machine can only utilize VHDX.
            if (($VMGeneration -eq 2) -and ($Type -eq 'VHD')) {

                throw ($localized.InvalidVhdTypeError -f 'VHD', 2);
            }

            if (($MaximumSizeBytes -lt 3145728) -or ($MaximumSizeBytes -gt 2190433320960)) {

                throw ($localized.InvalidVhdSizeError -f $MaximumSizeBytes);
            }
        }
        else {

            ## Nothing has been specified
            throw ($localized.CannotProcessCommandError -f '"Type, MaximumSizeBytes, VhdPath');
        }

    } #end process
} #end function

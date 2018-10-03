function Assert-VirtualMachineHardDiskDriveParameter {
<#
    .SYNOPSIS
        Ensures parameters specified in the Lability_HardDiskDrive hashtable are correct.
#>
    [CmdletBinding()]
    param (
        ## Virtual hard disk generation
        [Parameter()]
        [System.String] $Generation,

        ## Vhd size. Minimum 3MB and maximum 2,040GB
        [Parameter()]
        [Alias('Size')]
        [System.UInt64] $MaximumSizeBytes,

        [Parameter()]
        [System.String] $VhdPath,

        ## Virtual hard disk type
        [Parameter()]
        [ValidateSet('Dynamic','Fixed')]
        [System.String] $Type,

        [Parameter()]
        [System.UInt32] $VMGeneration
    )
    process {

        if ($PSBoundParameters.ContainsKey('VhdPath')) {

            if (($PSBoundParameters.Keys -contains 'Generation') -or
                ($PSBoundParameters.Keys -contains 'MaximumSizeBytes')) {

                throw ($localized.CannotResoleVhdParameterError);
            }

            if (-not (Test-Path -Path $VhdPath -PathType Leaf)) {

                throw ($localized.CannotLocateVhdError -f $VhdPath);
            }
        }
        elseif ($PSBoundParameters.ContainsKey('Generation')) {

            ## A Generation 2 virtual machine can only utilize VHDX.
            if (($VMGeneration -eq 2) -and ($Generation -eq 'VHD')) {

                throw ($localized.InvalidVhdTypeError -f 'VHD', 2);
            }

            if (($MaximumSizeBytes -lt 3145728) -or ($MaximumSizeBytes -gt 2190433320960)) {

                throw ($localized.InvalidVhdSizeError -f $MaximumSizeBytes);
            }
        }
        else {

            ## Nothing has been specified
            throw ($localized.CannotProcessCommandError -f '"Generation, MaximumSizeBytes, VhdPath');
        }

    } #end process
} #end function

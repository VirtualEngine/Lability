function Test-LabDscModule {
<#
    .SYNOPSIS
        Tests whether the ResourceName of the specified ModuleName can be located on the system.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $ModuleName,

        [Parameter()]
        [System.String] $ResourceName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $MinimumVersion
    )
    process {

        if (Get-LabDscModule @PSBoundParameters -ErrorAction SilentlyContinue) {

            return $true;
        }
        else {

            return $false;
        }

    } #end process
} #end function

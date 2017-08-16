function Assert-TimeZone {
<#
    .SYNOPSIS
        Validates a timezone string.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $TimeZone
    )
    process {

        try {

            $TZ = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            return $TZ.StandardName;
        }
        catch [System.TimeZoneNotFoundException] {

            throw $_;
        }

    } #end process
} #end function

function Test-ComputerName {
<#
    .SYNOPSIS
        Validates a computer name is valid.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateLength(1, 15)]
        [System.String] $ComputerName
    )
    process {

        $invalidMatch = '[~!@#\$%\^&\*\(\)=\+_\[\]{}\\\|;:.''",<>\/\?\s]';
        return ($ComputerName -inotmatch $invalidMatch);

    }
} #end function

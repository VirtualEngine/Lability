function TestComputerName {
<#
    .SYNOPSIS
        Validates a computer name is valid.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Source directory path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $ComputerName
    )
    process {

        $invalidMatch = '[~!@#\$%\^&\*\(\)=\+_\[\]{}\\\|;:.''",<>\/\?\s]';
        return ($ComputerName -inotmatch $invalidMatch);

    }
} #end function

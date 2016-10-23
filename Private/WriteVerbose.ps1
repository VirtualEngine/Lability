function WriteVerbose {

<#
    .SYNOPSIS
        Wrapper around Write-Verbose that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {
            $verboseMessage = GetFormattedMessage -Message $Message;
            Write-Verbose -Message $verboseMessage;
        }

    }

}


function WriteWarning {

<#
    .SYNOPSIS
        Wrapper around Write-Warning that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {
            $warningMessage = GetFormattedMessage -Message $Message;
            Write-Warning -Message $warningMessage;
        }

    }

}


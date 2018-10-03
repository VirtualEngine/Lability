function Write-Verbose {
<#
    .SYNOPSIS
        Proxy function for Write-Verbose that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {

            $verboseMessage = Get-FormattedMessage -Message $Message;
            Microsoft.PowerShell.Utility\Write-Verbose -Message $verboseMessage;
        }

    } #end process
} #end function

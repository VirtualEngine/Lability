function WriteWarning {
<#
    .SYNOPSIS
        Proxy function for Write-Warning that adds a timestamp and/or call stack information to the output.
#>
    [CmdletBinding()]
    [Alias('Write-Warning')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $Message
    )
    process {

        if (-not [System.String]::IsNullOrEmpty($Message)) {

            $warningMessage = Get-FormattedMessage -Message $Message;
            Microsoft.PowerShell.Utility\Write-Warning -Message $warningMessage;
        }

    } # end process
} #end function

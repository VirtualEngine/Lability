function GetFormattedMessage {

<#
    .SYNOPSIS
        Generates a formatted output message.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Message
    )
    process {

        if (($labDefaults.CallStackLogging) -and ($labDefaults.CallStackLogging -eq $true)) {
            $parentCallStack = (Get-PSCallStack)[1]; # store the parent Call Stack
            $functionName = $parentCallStack.FunctionName;
            $lineNumber = $parentCallStack.ScriptLineNumber;
            $scriptName = ($parentCallStack.Location -split ':')[0];
            $formattedMessage = '[{0}] [Script:{1}] [Function:{2}] [Line:{3}] {4}' -f (Get-Date).ToLongTimeString(), $scriptName, $functionName, $lineNumber, $Message;
        }
        else {
            $formattedMessage = '[{0}] {1}' -f (Get-Date).ToLongTimeString(), $Message;
        }
        return $formattedMessage;

    } #end process

}


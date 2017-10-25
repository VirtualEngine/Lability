function Invoke-Executable {
<#
    .SYNOPSIS
        Runs an executable and redirects StdOut and StdErr.
#>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        # Executable path
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        # Executable arguments
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Array] $Arguments,

        # Redirected StdOut and StdErr log name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LogName = ('{0}.log' -f $Path)
    )
    process {

        $processArgs = @{
            FilePath = $Path;
            ArgumentList = $Arguments;
            Wait = $true;
            RedirectStandardOutput = '{0}\{1}-StdOut.log' -f $env:temp, $LogName;
            RedirectStandardError = '{0}\{1}-StdErr.log' -f $env:temp, $LogName;
            NoNewWindow = $true;
            PassThru = $true;
        }
        Write-Debug -Message ($localized.RedirectingOutput -f 'StdOut', $processArgs.RedirectStandardOutput);
        Write-Debug -Message ($localized.RedirectingOutput -f 'StdErr', $processArgs.RedirectStandardError);
        Write-Verbose -Message ($localized.StartingProcess -f $Path, [System.String]::Join(' ', $Arguments));
        $process = Start-Process @processArgs;

        if ($process.ExitCode -ne 0) {

            Write-Warning -Message ($localized.ProcessExitCode -f $Path, $process.ExitCode)
        }
        else {

            Write-Verbose -Message ($localized.ProcessExitCode -f $Path, $process.ExitCode);
        }
        ##TODO: Should this actually return the exit code?!

    } #end process
} #end function

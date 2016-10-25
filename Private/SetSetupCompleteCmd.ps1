function SetSetupCompleteCmd {

<#
    .SYNOPSIS
        Creates a lab BootStrap script block.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ScriptBlock])]
    param (
        ## Destination SetupComplete.cmd directory path.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Is a CoreCLR VM. The bootstrapping via Powershell.exe in the CoreCLR doesn't work in its current format, i.e. with Nano Server
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {

        [ref] $null = NewDirectory -Path $Path;
        $setupCompletePath = Join-Path -Path $Path -ChildPath 'SetupComplete.cmd';
        if ($CoreCLR) {

            WriteVerbose -Message $localized.UsingCoreCLRSetupComplete;
            $setupCompleteCmd = @"
schtasks /create /tn "BootStrap" /tr "cmd.exe /c """Powershell.exe -Command %SYSTEMDRIVE%\BootStrap\BootStrap.ps1""" > %SYSTEMDRIVE%\BootStrap\BootStrap.log" /sc "Once" /sd "01/01/2099" /st "00:00" /ru "System"
schtasks /run /tn "BootStrap"
"@
        }
        else {

            WriteVerbose -Message $localized.UsingDefaultSetupComplete;
            $setupCompleteCmd = 'Powershell.exe -NoProfile -ExecutionPolicy Bypass -NonInteractive -File "%SYSTEMDRIVE%\BootStrap\BootStrap.ps1"';
        }
        Set-Content -Path $setupCompletePath -Value $setupCompleteCmd -Encoding Ascii -Force;

    } #end process

}


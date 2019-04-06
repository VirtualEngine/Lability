function Set-LabSetupCompleteCmd {
<#
    .SYNOPSIS
        Creates a lab BootStrap script block.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
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

        [ref] $null = New-Directory -Path $Path -Confirm:$false;
        $setupCompletePath = Join-Path -Path $Path -ChildPath 'SetupComplete.cmd';
        if ($CoreCLR) {

            Write-Verbose -Message $localized.UsingCoreCLRSetupComplete;
            $setupCompleteCmd = @"
schtasks /create /tn "BootStrap" /tr "cmd.exe /c """Powershell.exe -Command %SYSTEMDRIVE%\BootStrap\BootStrap.ps1""" > %SYSTEMDRIVE%\BootStrap\BootStrap.log" /sc "Once" /sd "01/01/2099" /st "00:00" /ru "System"
schtasks /run /tn "BootStrap"
"@
        }
        else {

            Write-Verbose -Message $localized.UsingDefaultSetupComplete;
            $setupCompleteCmd = 'Powershell.exe -NoProfile -ExecutionPolicy Bypass -NonInteractive -File "%SYSTEMDRIVE%\BootStrap\BootStrap.ps1"';
        }

        Set-Content -Path $setupCompletePath -Value $setupCompleteCmd -Encoding Ascii -Force -Confirm:$false;

    } #end process
} #end function

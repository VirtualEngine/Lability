function NewBootStrap {
<#
    .SYNOPSIS
        Creates a lab DSC BootStrap script block.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ScriptBlock])]
    param ( )
    process {
        $sciptBlock = {
            
        ## VirtualEngine.Lab DSC Bootstrap
        $VerbosePreference = 'Continue';
        $DebugPreference = 'Continue';
        Start-Transcript -Path "$env:SystemDrive\BootStrap\BootStrap.log" -Force;

        certutil.exe -addstore -f "Root" "$env:SYSTEMDRIVE\BootStrap\LabRoot.cer";
        ## Import the .PFX certificate with a blank password
        "" | certutil.exe -f -importpfx "$env:SYSTEMDRIVE\BootStrap\LabClient.pfx";

        <#CustomBootStrapInjectionPoint#>

        if (Test-Path -Path "$env:SystemDrive\BootStrap\localhost.meta.mof") {
            Set-DscLocalConfigurationManager -Path "$env:SystemDrive\BootStrap\" -Verbose;
        }

        while ($true) {
            ## Replay the configuration until the LCM bloody-well takes it!
            try {
                if (Test-Path -Path "$env:SystemDrive\BootStrap\localhost.mof") {
                    Start-DscConfiguration -Path "$env:SystemDrive\Bootstrap\" -Force -Wait -Verbose -ErrorAction Stop;
                }
                break;
            }
            catch {
                Write-Error $_;
                Start-Sleep -Seconds 5;
            }
        } #end while
        
        Stop-Transcript;
        } #end bootstrap scriptblock
        return $sciptBlock;
    } #end process
} #end function NewBootStrap

function SetSetupCompleteCmd {
<#
    .SYNOPSIS
        Creates a lab BootStrap script block.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ScriptBlock])]
    param (
        ## Destination SetupComplete.cmd directory path.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Path
    )
    process {
        [ref] $null = NewDirectory -Path $Path;
        $setupCompletePath = Join-Path -Path $Path -ChildPath 'SetupComplete.cmd';
        $setupCompleteCmd = 'Powershell.exe -NoProfile -ExecutionPolicy Bypass -NonInteractive -File "%SYSTEMDRIVE%\BootStrap\BootStrap.ps1"';
        Set-Content -Path $setupCompletePath -Value $setupCompleteCmd -Encoding Ascii -Force;
    } #end process
} #end function SetSetupCompleteCmd

function SetBootStrap {
<#
    .SYNOPSIS
        Writes the lab BootStrap.ps1 file to the target directory.
#>
    [CmdletBinding()]
    param (
        ## Destination Bootstrap directory path.
        [Parameter(Mandatory)] [System.String] $Path,
        ## Custom bootstrap script
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $CustomBootStrap
    )
    process {
        [ref] $null = NewDirectory -Path $Path;
        $bootStrapPath = Join-Path -Path $Path -ChildPath 'BootStrap.ps1';
        $bootStrap = (NewBootStrap).ToString();
        if ($CustomBootStrap) {
            $bootStrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $CustomBootStrap;
        }
        Set-Content -Path $bootStrapPath -Value $bootStrap -Encoding UTF8 -Force;
    } #end process
} #end function SetBootStrap

function NewBootStrap {
<#
    .SYNOPSIS
        Creates a lab DSC BootStrap script block.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ScriptBlock])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {
        $coreCLRScriptBlock = {
        ## VirtualEngine.Lab CoreCLR DSC Bootstrap
        $VerbosePreference = 'Continue';

        ## TODO: Need to find a Nano equivalent of CertUtil.exe!

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
                Write-Error -Message $_;
                Start-Sleep -Seconds 5;
            }
        } #end while
        
        } #end CoreCLR bootstrap scriptblock
        
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
                Write-Error -Message $_;
                Start-Sleep -Seconds 5;
            }
        } #end while
        
        Stop-Transcript;
        } #end bootstrap scriptblock
        
        if ($CoreCLR) {
            return $coreCLRScriptBlock;
        }
        else {
            return $sciptBlock;
        }
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
        [Parameter(Mandatory, ValueFromPipeline)] [ValidateNotNullOrEmpty()]
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
} #end function SetSetupCompleteCmd

function SetBootStrap {
<#
    .SYNOPSIS
        Writes the lab BootStrap.ps1 file to the target directory.
#>
    [CmdletBinding()]
    param (
        ## Destination Bootstrap directory path.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,
        
        ## Custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootStrap,

        ## Is a CoreCLR VM. The PowerShell switches are different in the CoreCLR, i.e. Nano Server
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR
    )
    process {
        [ref] $null = NewDirectory -Path $Path;
        $bootStrapPath = Join-Path -Path $Path -ChildPath 'BootStrap.ps1';
        $bootStrap = (NewBootStrap -CoreCLR:$CoreCLR).ToString();
        if ($CustomBootStrap) {
            $bootStrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $CustomBootStrap;
        }
        Set-Content -Path $bootStrapPath -Value $bootStrap -Encoding UTF8 -Force;
    } #end process
} #end function SetBootStrap

function ResolveCustomBootStrap {
<#
    .SYNOPSIS
        Resolves the media and node custom bootstrap, using the specified CustomBootstrapOrder
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## Custom bootstrap order
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('ConfigurationFirst','ConfigurationOnly','Disabled','MediaFirst','MediaOnly')]
        [System.String] $CustomBootstrapOrder,
        
        ## Node/configuration custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String] $ConfigurationCustomBootStrap,

        ## Media custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)] [AllowNull()]
        [System.String[]] $MediaCustomBootStrap
    )
    begin {
        if ([System.String]::IsNullOrWhiteSpace($ConfigurationCustomBootStrap)) {
            $ConfigurationCustomBootStrap = "";
        }
        ## Convert the string[] into a multi-line string
        if ($MediaCustomBootstrap) {
            $mediaBootstrap = [System.String]::Join("`r`n", $MediaCustomBootStrap);
        }
        else {
            $mediaBootstrap = "";
        }
    } #end begin
    process {
        switch ($CustomBootstrapOrder) {
            'ConfigurationFirst' {
                $bootStrap = "{0}`r`n{1}" -f $ConfigurationCustomBootStrap, $mediaBootstrap;
            }
            'ConfigurationOnly' {
                $bootStrap = $ConfigurationCustomBootStrap;
            }
            'MediaFirst' {
                $bootStrap = "{0}`r`n{1}" -f $mediaBootstrap, $ConfigurationCustomBootStrap;
            }
            'MediaOnly' {
                $bootStrap = $mediaBootstrap;
            }
            Default {
                #Disabled
            }
        } #end switch
        return $bootStrap;
    } #end process
} #end function ResolveCustomBootStrap

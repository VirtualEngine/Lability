function NewBootStrap {
<#
    .SYNOPSIS
        Creates a lab DSC BootStrap script block.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom default shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell
    )
    process {

        $coreCLRScriptBlock = {
## Lability CoreCLR DSC Bootstrap
$VerbosePreference = 'Continue';

Import-Certificate -FilePath "$env:SYSTEMDRIVE\BootStrap\LabRoot.cer" -CertStoreLocation 'Cert:\LocalMachine\Root\' -Verbose;
## Import the .PFX certificate with a blank password
Import-PfxCertificate -FilePath "$env:SYSTEMDRIVE\BootStrap\LabClient.pfx" -CertStoreLocation 'Cert:\LocalMachine\My\' -Verbose;

<#CustomBootStrapInjectionPoint#>

if (Test-Path -Path "$env:SystemDrive\BootStrap\localhost.meta.mof") {
    Set-DscLocalConfigurationManager -Path "$env:SystemDrive\BootStrap\" -Verbose;
}

if (Test-Path -Path "$env:SystemDrive\BootStrap\localhost.mof") {
    Start-DscConfiguration -Path "$env:SystemDrive\Bootstrap\" -Force -Wait -Verbose -ErrorAction Stop;
} #end if localhost.mof

} #end CoreCLR bootstrap scriptblock

        $scriptBlock = {
## Lability DSC Bootstrap
$VerbosePreference = 'Continue';
$DebugPreference = 'Continue';
$transcriptPath = '{0}\BootStrap\Bootstrap-{1}.log' -f $env:SystemDrive, (Get-Date).ToString('yyyyMMdd-hhmmss');
Start-Transcript -Path $transcriptPath -Force;

certutil.exe -addstore -f "Root" "$env:SYSTEMDRIVE\BootStrap\LabRoot.cer";
## Import the .PFX certificate with a blank password
"" | certutil.exe -f -importpfx "$env:SYSTEMDRIVE\BootStrap\LabClient.pfx";

<#CustomBootStrapInjectionPoint#>

## Account for large configurations being "pushed" and increase the default from 500KB to 1024KB (1MB)
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 1024 -Force -Verbose;

if (Test-Path -Path "$env:SystemDrive\BootStrap\localhost.meta.mof") {
    Set-DscLocalConfigurationManager -Path "$env:SystemDrive\BootStrap\" -Verbose;
}

$localhostMofPath = "$env:SystemDrive\BootStrap\localhost.mof";
if (Test-Path -Path $localhostMofPath) {

    if ($PSVersionTable.PSVersion.Major -eq 4) {

        ## Convert the .mof to v4 compatible - credit to Mike Robbins
        ## http://mikefrobbins.com/2014/10/30/powershell-desired-state-configuration-error-undefined-property-configurationname/
        $mof = Get-Content -Path $localhostMofPath;
        $mof -replace '^\sName=.*;$|^\sConfigurationName\s=.*;$' | Set-Content -Path $localhostMofPath -Encoding Unicode -Force;
    }
    while ($true) {
        ## Replay the configuration until the LCM bloody-well takes it (more of a WMF 4 thing)!
        try {

            if (Test-Path -Path "$env:SystemRoot\System32\Configuration\Pending.mof") {

                Start-DscConfiguration -UseExisting -Force -Wait -Verbose -ErrorAction Stop;
                break;
            }
            else {

                Start-DscConfiguration -Path "$env:SystemDrive\Bootstrap\" -Force -Wait -Verbose -ErrorAction Stop;
                break;
            }
        }
        catch {

            Write-Error -Message $_;
            ## SIGH. Try restarting WMI..
            if (-not ($interation % 10)) {

                ## SIGH. Try removing the configuration and restarting WMI..
                Remove-DscConfigurationDocument -Stage Current,Pending,Previous -Force;
                Restart-Service -Name Winmgmt -Force;
            }
            Start-Sleep -Seconds 5;
            $interation++;
        }
    } #end while
} #end if localhost.mof

Stop-Transcript;
} #end bootstrap scriptblock

        if ($CoreCLR) {

            $bootstrap = $coreCLRScriptBlock.ToString();
        }
        else {

            $bootstrap = $scriptBlock.ToString();
        }

        if ($PSBoundParameters.ContainsKey('DefaultShell')) {

            $shellScriptBlock = {
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' -Name Shell -Value '{0}' -Force;

                <#CustomBootStrapInjectionPoint#>
            }

            $shellScriptBlockString = $shellScriptBlock.ToString() -f $DefaultShell;
            $bootstrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $shellScriptBlockString;
        }

        return $bootstrap;

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
        Set-Content -Path $setupCompletePath -Value $setupCompleteCmd -Encoding Ascii -Force -Confirm:$false;

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
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CustomBootStrap,

        ## Is a CoreCLR VM. The PowerShell switches are different in the CoreCLR, i.e. Nano Server
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell
    )
    process {

        $newBootStrapParams = @{
            CoreCLR = $CoreCLR;
        }
        if (-not [System.String]::IsNullOrEmpty($DefaultShell)) {

            $newBootStrapParams['DefaultShell'] = $DefaultShell;
        }
        $bootStrap = NewBootStrap @newBootStrapParams;

        if ($CustomBootStrap) {

            $bootStrap = $bootStrap -replace '<#CustomBootStrapInjectionPoint#>', $CustomBootStrap;
        }

        [ref] $null = New-Directory -Path $Path -Confirm:$false;
        $bootStrapPath = Join-Path -Path $Path -ChildPath 'BootStrap.ps1';
        Set-Content -Path $bootStrapPath -Value $bootStrap -Encoding UTF8 -Force -Confirm:$false;

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
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $ConfigurationCustomBootStrap,

        ## Media custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
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

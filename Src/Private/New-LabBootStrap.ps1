function New-LabBootStrap {
<#
    .SYNOPSIS
        Creates a lab DSC BootStrap script block.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [OutputType([System.String])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $CoreCLR,

        ## Custom default shell
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DefaultShell,

        ## WSMan maximum envelope size
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Int32] $MaxEnvelopeSizeKb = 1024
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

## Account for large configurations being "pushed" and increase the default from 500KB to <#MaxEnvelopeSizeKb#>KB (#306)
Set-ItemProperty -LiteralPath HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client -Name maxEnvelopeSize -Value <#MaxEnvelopeSizeKb#> -Force -Verbose

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
            $bootstrap = $bootStrap.Replac('<#CustomBootStrapInjectionPoint#>', $shellScriptBlockString);
        }

        $bootstrap = $bootstrap -replace  '<#MaxEnvelopeSizeKb#>', $MaxEnvelopeSizeKb;
        return $bootstrap;

    } #end process
} #end function

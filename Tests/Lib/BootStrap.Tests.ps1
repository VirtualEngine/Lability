#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Lib\BootStrap' {

    InModuleScope $moduleName {

        Context 'Validates NewBootStrap method' {

            It 'Returns a "System.String" type' {
                $bootstrap = NewBootStrap;

                $bootstrap -is [System.String] | Should Be $true;
            }

            It 'Includes custom BootStrap injection point' {
                $bootstrap = NewBootStrap;

                $bootstrap.ToString() -match "<#CustomBootStrapInjectionPoint#>`r`n" | Should Be $true;
            }

        } #end context Validates NewBootStrap method

        Context 'Validates "SetSetupCompleteCmd" method' {

            It 'Creates target file "SetupComplete.cmd"' {
                SetSetupCompleteCmd -Path TestDrive:\;
                Test-Path -Path "TestDrive:\SetupComplete.cmd" | Should Be $true;
            }

            It 'Bypasses Powershell execution policy' {
                SetSetupCompleteCmd -Path TestDrive:\;
                $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";

                $setupCompleteCmd -match '-ExecutionPolicy Bypass' | Should Be $true;
            }

            It 'Runs non-interactively' {
                SetSetupCompleteCmd -Path TestDrive:\;
                $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";

                $setupCompleteCmd -match '-NonInteractive' | Should Be $true;
            }

            It 'Creates scheduled tasks for CoreCLR image' {
                ## Must execute before we mock Set-Content!
                SetSetupCompleteCmd -Path TestDrive:\ -CoreCLR;
                $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";

                ($setupCompleteCmd -match 'Schtasks') -as [System.Boolean] | Should Be $true;
            }

            It 'Uses ASCII encoding' {
                Mock Set-Content -ParameterFilter { $Encoding -eq 'ASCII' } -MockWith { }

                SetSetupCompleteCmd -Path TestDrive:\;

                Assert-MockCalled Set-Content -ParameterFilter { $Encoding -eq 'ASCII' } -Scope It
            }

        } #end context Validates "SetSetupCompleteCmd" method

        Context 'Validates "SetBootStrap" method' {

            It 'Creates target file "BootStrap.ps1"' {
                SetBootStrap -Path TestDrive:\;

                Test-Path -Path "TestDrive:\BootStrap.ps1" | Should Be $true;
            }

            It 'Replaces custom BootStrap injection point with custom BootStrap' {
                $customBootStrap = 'This is a test custom bootstrap example';

                SetBootStrap -Path TestDrive:\ -CustomBootStrap $customBootStrap;
                $bootStrap = Get-Content -Path "TestDrive:\BootStrap.ps1";

                $bootStrap -match $customBootStrap | Should Be $true;
                $bootStrap -match "<#CustomBootStrapInjectionPoint#>" | Should BeNullOrEmpty;
            }

            It 'Uses UTF8 encoding' {
                Mock Set-Content -ParameterFilter { $Encoding -eq 'UTF8' } -MockWith { }

                SetBootStrap -Path TestDrive:\;

                Assert-MockCalled Set-Content -ParameterFilter { $Encoding -eq 'UTF8' } -Scope It
            }

        } #end context Validates "SetBootStrap" method

        Context 'Validates "ResolveCustomBootStrap" method' {

            It 'Returns empty string when "CustomBootStrapOrder" = "Disabled"' {
                $configurationBootstrap = 'Configuration';
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder Disabled -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should BeNullOrEmpty;
            }

            It 'Returns configuration bootstrap when "CustomBootStrapOrder" = "ConfigurationOnly"' {
                $configurationBootstrap = 'Configuration';
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder ConfigurationOnly -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should Be $configurationBootstrap;
            }

            It 'Returns media bootstrap when "CustomBootStrapOrder" = "MediaOnly"' {
                $configurationBootstrap = 'Configuration';
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder MediaOnly -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should Be $mediaBootstrap;
            }

            It 'Returns configuration bootstrap first when "CustomBootStrapOrder" = "ConfigurationFirst"' {
                $configurationBootstrap = 'Configuration';
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder ConfigurationFirst -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should Be "$configurationBootStrap`r`n$mediaBootstrap";
            }

            It 'Returns media bootstrap first when "CustomBootStrapOrder" = "MediaFirst"' {
                $configurationBootstrap = 'Configuration';
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder MediaFirst -ConfigurationCustomBootstrap $configurationBootstrap -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should Be "$mediaBootstrap`r`n$configurationBootStrap";
            }

            It 'Returns configuration bootstrap when "MediaCustomBootstrap" is null' {
                $configurationBootstrap = 'Configuration';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder ConfigurationFirst -ConfigurationCustomBootstrap $configurationBootstrap;

                $bootstrap | Should Be "$configurationBootStrap`r`n$mediaBootstrap";
            }

            It 'Returns media bootstrap when "ConfigurationCustomBootstrap" is null' {
                $mediaBootstrap = 'Media';

                $bootstrap = ResolveCustomBootstrap -CustomBootstrapOrder MediaFirst -MediaCustomBootstrap $mediaBootstrap;

                $bootstrap | Should Be "$mediaBootstrap`r`n$configurationBootStrap";
            }

        } #end context Validates "ResolveCustomBootStrap" method

    } #end InModuleScope

} #end describe Lib\Bootstrap

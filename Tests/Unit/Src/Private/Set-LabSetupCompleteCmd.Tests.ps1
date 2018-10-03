#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-LabSetupCompleteCmd' {

    InModuleScope $moduleName {

        It 'Creates target file "SetupComplete.cmd"' {
            Set-LabSetupCompleteCmd -Path TestDrive:\;
            Test-Path -Path "TestDrive:\SetupComplete.cmd" | Should Be $true;
        }

        It 'Bypasses Powershell execution policy' {
            Set-LabSetupCompleteCmd -Path TestDrive:\;
            $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";

            $setupCompleteCmd -match '-ExecutionPolicy Bypass' | Should Be $true;
        }

        It 'Runs non-interactively' {
            Set-LabSetupCompleteCmd -Path TestDrive:\;
            $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";

            $setupCompleteCmd -match '-NonInteractive' | Should Be $true;
        }

        It 'Creates scheduled tasks for CoreCLR image' {
            ## Must execute before we mock Set-Content!
            Set-LabSetupCompleteCmd -Path TestDrive:\ -CoreCLR;
            $setupCompleteCmd = Get-Content -Path "TestDrive:\SetupComplete.cmd";
            @($setupCompleteCmd -match 'Schtasks').Count -gt 0 | Should Be $true;
        }

        It 'Uses ASCII encoding' {
            Mock Set-Content -ParameterFilter { $Encoding -eq 'ASCII' } -MockWith { }

            Set-LabSetupCompleteCmd -Path TestDrive:\;

            Assert-MockCalled Set-Content -ParameterFilter { $Encoding -eq 'ASCII' } -Scope It
        }

    } #end InModuleScope
} #end Describe

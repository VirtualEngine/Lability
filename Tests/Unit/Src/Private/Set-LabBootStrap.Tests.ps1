#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-LabBootStrap' {

    InModuleScope $moduleName {

        It 'Creates target file "BootStrap.ps1"' {
            Set-LabBootStrap -Path TestDrive:\;

            Test-Path -Path "TestDrive:\BootStrap.ps1" | Should Be $true;
        }

        It 'Replaces custom BootStrap injection point with custom BootStrap' {
            $customBootStrap = 'This is a test custom bootstrap example';

            Set-LabBootStrap -Path TestDrive:\ -CustomBootStrap $customBootStrap;
            $bootStrap = Get-Content -Path "TestDrive:\BootStrap.ps1";

            $bootStrap -match $customBootStrap | Should Be $true;
            $bootStrap -match "<#CustomBootStrapInjectionPoint#>" | Should BeNullOrEmpty;
        }

        It 'Uses UTF8 encoding' {
            Mock Set-Content -ParameterFilter { $Encoding -eq 'UTF8' } -MockWith { }

            Set-LabBootStrap -Path TestDrive:\;

            Assert-MockCalled Set-Content -ParameterFilter { $Encoding -eq 'UTF8' } -Scope It
        }

    } #end InModuleScope
} #end Describe

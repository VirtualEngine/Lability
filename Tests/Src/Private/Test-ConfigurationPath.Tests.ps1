#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-ConfigurationPath' {

    InModuleScope -ModuleName $moduleName {

        It 'returns $true when .mof found' {

            $testName = 'VM01';
            New-Item -Path "TestDrive:\$testName.mof" -ItemType File -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path "TestDrive:\$testName.meta.mof" -Force -ErrorAction SilentlyContinue;

            $result = Test-ConfigurationPath -Path 'TestDrive:\' -Name $testName;

            $result | Should Be $true;
        }

        It 'returns $true when .meta.mof found' {

            $testName = 'VM01';
            New-Item -Path "TestDrive:\$testName.meta.mof" -ItemType File -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path "TestDrive:\$testName.mof" -Force -ErrorAction SilentlyContinue;

            $result = Test-ConfigurationPath -Path 'TestDrive:\' -Name $testName;

            $result | Should Be $true;
        }

        It 'returns $false when .mof and .meta.mof not found' {

            $testName = 'VM01';
            Remove-Item -Path "TestDrive:\$testName.mof" -Force -ErrorAction SilentlyContinue;
            Remove-Item -Path "TestDrive:\$testName.meta.mof" -Force -ErrorAction SilentlyContinue;

            $result = Test-ConfigurationPath -Path 'TestDrive:\' -Name $testName;

            $result | Should Be $false;
        }

    } #end InModuleScope
} #end describe

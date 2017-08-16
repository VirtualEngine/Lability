#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-DscResourceModule' {

    InModuleScope $moduleName {

        It 'Returns "True" when the module contains a "DSCResources" folder' {
            $testModuleName = 'Module';
            $testModulePath = "TestDrive:\$testModuleName";
            [ref] $null = New-Item -Path "$testModulePath\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;

            Test-DscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $true;
        }

        It 'Returns "False" when the module does not contain a "DSCResources" folder' {
            $testModuleName = 'Module';
            $testModulePath = "TestDrive:\$testModuleName";
            [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;

            Test-DscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $false;
        }

        It 'Returns "True" when the module .psm1 contains a "[DSCResource()]" definition' {
            $testModuleName = 'Module';
            $testModulePath = "TestDrive:\$testModuleName";
            [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;
            Set-Content -Path "$testModulePath\$testModuleName.psm1" -Value "enum Ensure { `r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;

            Test-DscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $true;
        }

        It 'Returns "False" when the module .psm1 does not contain a "[DSCResource()]" definition' {
            $testModuleName = 'Module';
            $testModulePath = "TestDrive:\$testModuleName";
            [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;
            Set-Content -Path "$testModulePath\$testModuleName.psm1" -Value "enum Ensure { `r`n Absent `r`n Present `r`n } `r`n These are not the droids you're looking for! `r`n" -Force;

            Test-DscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $false;
        }

    } #end InModuleScope
} #end Describe

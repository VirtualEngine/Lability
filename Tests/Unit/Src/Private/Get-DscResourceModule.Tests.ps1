#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-DscResourceModule' {

    InModuleScope $moduleName {

        It 'Returns module with "DSCResources"' {
            $testModuleName = 'TestModule';
            $testModuleVersion = '3.2.1';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = New-Item -Path "$testModulesPath\$testModuleName\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;
            [ref] $null = New-Item -Path "$testModulesPath\$testModuleName\$testModuleName.psd1" -ItemType File -Force -ErrorAction SilentlyContinue;

            Mock ConvertTo-ConfigurationData -MockWith { return [PSCustomObject] @{ ModuleVersion = $testModuleVersion; } }

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module.ModuleVersion | Should Be $testModuleVersion;
        }

        It 'Returns module with "[DSCResource()]"' {
            $testModuleName = 'TestModule';
            $testModuleVersion = '3.2.1';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\DSCResources" -Force -ErrorAction SilentlyContinue;
            Set-Content -Path "$testModulesPath\$testModuleName\$testModuleName.psm1" -Value "enum Ensure {`r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;
            Mock ConvertTo-ConfigurationData -MockWith { return [PSCustomObject] @{ ModuleVersion = $testModuleVersion; } }

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module.ModuleVersion | Should Be $testModuleVersion;
        }

        It 'Does not return a module without "DSCResources" and "[DSCResource()]"' {
            $testModuleName = 'TestModule';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\DSCResources" -Force -ErrorAction SilentlyContinue;
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleName.psm1" -Force -ErrorAction SilentlyContinue;

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module | Should BeNullOrEmpty;
        }

        It 'Returns versioned module with "DSCResources"' {
            $testModuleName = 'TestModule';
            $testModuleVersion = '3.2.42';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = New-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;
            Mock ConvertTo-ConfigurationData -MockWith { return [PSCustomObject] @{ ModuleVersion = $testModuleVersion; } }

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module.ModuleVersion | Should Be $testModuleVersion;
        }

        It 'Returns versioned module with "[DSCResource()]"' {
            $testModuleName = 'TestModule';
            $testModuleVersion = '3.2.42';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -Force -ErrorAction SilentlyContinue;
            Set-Content -Path "$testModulesPath\$testModuleName\$testModuleVersion\$testModuleName.psm1" -Value "enum Ensure {`r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;
            Mock ConvertTo-ConfigurationData -MockWith { return [PSCustomObject] @{ ModuleVersion = $testModuleVersion; } }

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module.ModuleVersion | Should Be $testModuleVersion;
        }

        It 'Does not return a versioned module without "DSCResources" and "[DSCResource()]"' {
            $testModuleName = 'TestModule';
            $testModuleVersion = '3.2.42';
            $testModulesName = 'Modules';
            $testModulesPath = "TestDrive:\$testModulesName";
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -Force -ErrorAction SilentlyContinue;
            [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\$testModuleName.psm1" -Force -ErrorAction SilentlyContinue;

            $module = Get-DscResourceModule -Path $testModulesPath;

            $module | Should BeNullOrEmpty;
        }

    } #end InModuleScope
} #end Describe

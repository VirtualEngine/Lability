#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'DscModule' {
    
    InModuleScope $moduleName {

        Context 'Validates "TestDscResourceModule" method' {

            It 'Returns "True" when the module contains a "DSCResources" folder' {
                $testModuleName = 'Module';
                $testModulePath = "TestDrive:\$testModuleName";
                [ref] $null = New-Item -Path "$testModulePath\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;
            
                TestDscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $true;
            }
            
            It 'Returns "False" when the module does not contain a "DSCResources" folder' {
                $testModuleName = 'Module';
                $testModulePath = "TestDrive:\$testModuleName";
                [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;
            
                TestDscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $false;
            }

            It 'Returns "True" when the module .psm1 contains a "[DSCResource()]" definition' {
                $testModuleName = 'Module';
                $testModulePath = "TestDrive:\$testModuleName";
                [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;
                Set-Content -Path "$testModulePath\$testModuleName.psm1" -Value "enum Ensure { `r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;

                TestDscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $true;
            }

            It 'Returns "False" when the module .psm1 does not contain a "[DSCResource()]" definition' {
                $testModuleName = 'Module';
                $testModulePath = "TestDrive:\$testModuleName";
                [ref] $null = Remove-Item -Path "$testModulePath\DSCResources" -Force -ErrorAction SilentlyContinue;
                Set-Content -Path "$testModulePath\$testModuleName.psm1" -Value "enum Ensure { `r`n Absent `r`n Present `r`n } `r`n These are not the droids you're looking for! `r`n" -Force;

                TestDscResourceModule -Path $testModulePath -ModuleName $testModuleName | Should Be $false;
            }

        } #end context Validates "TestDscResourceModule" method

        Context 'Validates "GetDscResourceModule" method' {

            It 'Returns module with "DSCResources"' {
                $testModuleName = 'TestModule';
                $testModuleVersion = '3.2.1';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = New-Item -Path "$testModulesPath\$testModuleName\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;
                Mock Test-ModuleManifest -MockWith { return [PSCustomObject] @{ Version = $testModuleVersion; } }

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module.ModuleVersion | Should Be $testModuleVersion;
            }

            It 'Returns module with "[DSCResource()]"' {
                $testModuleName = 'TestModule';
                $testModuleVersion = '3.2.1';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\DSCResources" -Force -ErrorAction SilentlyContinue;
                Set-Content -Path "$testModulesPath\$testModuleName\$testModuleName.psm1" -Value "enum Ensure {`r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;
                Mock Test-ModuleManifest -MockWith { return [PSCustomObject] @{ Version = $testModuleVersion; } }

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module.ModuleVersion | Should Be $testModuleVersion;
            }

            It 'Does not return a module without "DSCResources" and "[DSCResource()]"' {
                $testModuleName = 'TestModule';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\DSCResources" -Force -ErrorAction SilentlyContinue;
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleName.psm1" -Force -ErrorAction SilentlyContinue;

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module | Should BeNullOrEmpty;
            }

            It 'Returns versioned module with "DSCResources"' {
                $testModuleName = 'TestModule';
                $testModuleVersion = '3.2.42';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = New-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -ItemType Directory -Force -ErrorAction SilentlyContinue;
                Mock Test-ModuleManifest -MockWith { return [PSCustomObject] @{ Version = $testModuleVersion; } }

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module.ModuleVersion | Should Be $testModuleVersion;
            }

            It 'Returns versioned module with "[DSCResource()]"' {
                $testModuleName = 'TestModule';
                $testModuleVersion = '3.2.42';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -Force -ErrorAction SilentlyContinue;
                Set-Content -Path "$testModulesPath\$testModuleName\$testModuleVersion\$testModuleName.psm1" -Value "enum Ensure {`r`n Absent `r`n Present `r`n } `r`n [DSCResource()] `r`n" -Force;
                Mock Test-ModuleManifest -MockWith { return [PSCustomObject] @{ Version = $testModuleVersion; } }

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module.ModuleVersion | Should Be $testModuleVersion;
            }

            It 'Does not return a versioned module without "DSCResources" and "[DSCResource()]"' {
                $testModuleName = 'TestModule';
                $testModuleVersion = '3.2.42';
                $testModulesName = 'Modules';
                $testModulesPath = "TestDrive:\$testModulesName";
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\DSCResources" -Force -ErrorAction SilentlyContinue;
                [ref] $null = Remove-Item -Path "$testModulesPath\$testModuleName\$testModuleVersion\$testModuleName.psm1" -Force -ErrorAction SilentlyContinue;

                $module = GetDscResourceModule -Path $testModulesPath;
                
                $module | Should BeNullOrEmpty;
            }

        } #end context Validates "GetDscResourceModule" method

    } #end InModuleScope

} #end describe DscModule

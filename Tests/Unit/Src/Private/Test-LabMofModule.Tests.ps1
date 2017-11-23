#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabMofModule' {

    InModuleScope -ModuleName $moduleName {

        It 'Passes when module is defined (no version)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule1'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams -WarningAction SilentlyContinue;

            $result | Should Be $true;
        }

        It 'Fails when module is not defined (no version)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams -WarningAction SilentlyContinue;

            $result | Should Be $false;
        }

        It 'Passes when module version matches (MinimumVersion)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule1'; MinimumVersion = '1.2.3'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '1.2.3'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams -WarningAction SilentlyContinue;

            $result | Should Be $true;
        }

        It 'Fails when module version does not match (MinimumVersion)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule1'; MinimumVersion = '1.2.3'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '3.2.1'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams -WarningAction SilentlyContinue;

            $result | Should Be $false;
        }

        It 'Passes when module version matches (RequiredVersion)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '1.2.3'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '1.2.3'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams #-WarningAction SilentlyContinue;

            $result | Should Be $true;
        }

        It 'Fails when module version does not match (RequiredVersion)' {

            $testLabModModuleParams = @{
                Module = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '1.2.3'; }
                )
                MofModule = @(
                    @{ Name = 'TestModule1'; RequiredVersion = '3.2.1'; }
                )
            }
            $result = Test-LabMofModule @testLabModModuleParams -WarningAction SilentlyContinue;

            $result | Should Be $false;
        }

    } #end InModuleScope

} #end describe

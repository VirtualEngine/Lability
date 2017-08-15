#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabModuleCache' {

    InModuleScope -ModuleName $moduleName {

        $testModuleName = 'TestModule';
        $testPSGalleryModule = @{
            Name = $testModuleName; Version = '1.2.3.4';
        }

        It 'Passes when module is found' {
            Mock Get-LabModuleCache -MockWith { return $testPSGalleryModule; }
            $testLabModuleCacheParams = @{
                Name = $testModuleName;
            }

            $result = Test-LabModuleCache @testLabModuleCacheParams;

            $result | Should Be $true;
        }

        It 'Fails when module is not found' {
            Mock Get-LabModuleCache -MockWith { }
            $testLabModuleCacheParams = @{
                Name = $testModuleName;
            }

            $result = Test-LabModuleCache @testLabModuleCacheParams;

            $result | Should Be $false;
        }

    } #end InModuleScope

} #end describe

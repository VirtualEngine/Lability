#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-LabDscModule' {

    InModuleScope $moduleName {

        It 'Returns true if "Get-LabDscModule" returns a path' {
            $testModuleName = 'TestLabModule';
            $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
            Mock Get-LabDscModule -MockWith { return $testModulePath; }

            Test-LabDscModule -ModuleName $testModuleName | Should Be $true;
        }

        It 'Returns false if "Get-LabDscModule" fails' {
            $testModuleName = 'TestLabModule';
            $testModulePath = (New-Item -Path (Join-Path -Path 'TestDrive:\' -ChildPath "$testModuleName\$testModuleName.psm1") -ItemType Directory -Force).FullName;
            Mock Get-LabDscModule -MockWith { Write-Error "DSC module\resource '$testModuleName' not found."; }

            Test-LabDscModule -ModuleName $testModuleName | Should Be $false;
        }

    } #end InModuleScope
} #end Describe

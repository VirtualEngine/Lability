#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Import-LabDscResource' {

    InModuleScope $moduleName {

        It 'Does not import module if command is already imported' {
            $testModuleName = 'TestLabModule';
            $testResourceName = 'TestLabResource';
            $testPrefixedCommandName = "Test-$($testResourceName)TargetResource";
            Mock Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -MockWith { return $true; }

            Import-LabDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

            Assert-MockCalled Get-Command -ParameterFilter { $Name -eq $testPrefixedCommandName } -Scope It;
        }

        It 'Does not call "Get-LabDscModule" if "UseDefault" is not specified' {
            $testModuleName = 'TestLabModule';
            $testResourceName = 'TestLabResource';
            Mock Import-Module -MockWith { };
            Mock Get-Command -MockWith { };
            Mock Get-LabDscModule -MockWith { }

            Import-LabDscResource -ModuleName $testModuleName -ResourceName $testResourceName;

            Assert-MockCalled Get-LabDscModule -Scope It -Exactly 0;
        }

        It 'Calls "Get-LabDscModule" if "UseDefault" is specified' {
            $testModuleName = 'TestLabModule';
            $testResourceName = 'TestLabResource';
            Mock Import-Module -MockWith { };
            Mock Get-Command -MockWith { };
            Mock Get-LabDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -MockWith { return $env:TEMP; }

            Import-LabDscResource -ModuleName $testModuleName -ResourceName $testResourceName -UseDefault;

            Assert-MockCalled Get-LabDscModule -ParameterFilter { $ModuleName -eq $testModuleName -and $ResourceName -eq $testResourceName } -Scope It;
        }

    } #end InModuleScope
} #end Describe

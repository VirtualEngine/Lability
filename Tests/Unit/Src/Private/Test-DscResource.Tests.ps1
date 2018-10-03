#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-LabDscResource' {

    InModuleScope $moduleName {

        ## Cannot dynamically generate function names :|
        $testPrefixedCommandName = 'Test-TestLabResourceTargetResource';
        function Test-TestLabResourceTargetResource { }

        It 'Calls "Test-<ResourceName>TargetResource" method' {
            $testResourceName = 'TestLabResource';
            Mock $testPrefixedCommandName -MockWith { }

            Test-LabDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

            Assert-MockCalled $testPrefixedCommandName -Scope It;
        }

        It 'Return $false when "Test-<ResourceName>TargetResource" throws (#104)' {
            $testResourceName = 'TestLabResource';
            Mock $testPrefixedCommandName -MockWith { throw 'HideMe'; }

            $testResult = Test-LabDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 } -WarningAction SilentlyContinue;

            $testResult | Should Be $false;
        }

    } #end InModuleScope
} #end Describe

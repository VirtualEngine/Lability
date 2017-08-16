#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-LabDscResource' {

    InModuleScope $moduleName {

        It 'Calls "Set-<ResourceName>TargetResource" method' {
            $testResourceName = 'TestLabResource';
            ## Cannot dynamically generate function names :|
            $setPrefixedCommandName = 'Set-TestLabResourceTargetResource';
            function Set-TestLabResourceTargetResource { }
            Mock $setPrefixedCommandName -MockWith { }

            Set-LabDscResource -ResourceName $testResourceName -Parameters @{ TestParam = 1 };

            Assert-MockCalled $setPrefixedCommandName -Scope It;
        }

    } #end InModuleScope
} #end Describe

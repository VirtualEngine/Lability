#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-LabDscResource' {

    InModuleScope $moduleName {

        It 'Calls "Get-<ResourceName>TargetResource" method' {
            $testResourceName = 'TestLabResource';
            ## Cannot dynamically generate function names :|
            $getPrefixedCommandName = "Get-TestLabResourceTargetResource";
            function Get-TestLabResourceTargetResource { }
            Mock $getPrefixedCommandName -MockWith { }

            Get-LabDscResource -ResourceName $testResourceName -Parameters @{};

            Assert-MockCalled $getPrefixedCommandName -Scope It;
        }

    } #end InModuleScope
} #end Describe

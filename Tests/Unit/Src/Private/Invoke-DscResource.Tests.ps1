#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Invoke-LabDscResource' {

    InModuleScope $moduleName {

        It 'Does not call "Set-<ResourceName>TargetResource" if "TestDscResource" passes' {
            $testResourceName = 'TestLabResource';

            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $true; }
            Mock Set-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

            Invoke-LabDscResource -ResourceName $testResourceName -Parameters @{};

            Assert-MockCalled Set-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It -Exactly 0;
        }

        It 'Does call "Set-<ResourceName>TargetResource" if "TestDscResource" fails' {
            $testResourceName = 'TestLabResource';

            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }
            Mock Set-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { }

            Invoke-LabDscResource -ResourceName $testResourceName -Parameters @{};

            Assert-MockCalled Set-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -Scope It;
        }

        It 'Throws when "TestDscResource" fails and "ResourceName" matches "PendingReboot"' {
            $testResourceName = 'TestLabResourcePendingReboot';
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq $testResourceName } -MockWith { return $false; }

            { Invoke-LabDscResource -ResourceName $testResourceName -Parameters @{} } | Should Throw;
        }

    } #end InModuleScope
} #end Describe

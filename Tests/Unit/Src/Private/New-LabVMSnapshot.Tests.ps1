#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\New-LabVMSnapshot' {

    InModuleScope -ModuleName $moduleName {

        It 'Calls "Checkpoint-VM" for each virtual machine specified' {
            $testVMNames = 'TestVM1','TestVM2';
            $testSnapshotName = 'Test snapshot';
            Mock Checkpoint-VM -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

            New-LabVMSnapshot -Name $testVMNames -SnapshotName $testSnapshotName;

            Assert-MockCalled Checkpoint-VM -Exactly $testVMNames.Count -Scope It;
        }

    } #end InModuleScope

} #end describe

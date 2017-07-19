#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-LabVMSnapshot' {

    InModuleScope -ModuleName $moduleName {

        It 'Calls "Get-VMSnapshot" for each virtual machine specified' {
            $testVMNames = 'TestVM1','TestVM2';
            $testSnapshotName = 'Test snapshot';
            Mock Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -MockWith { return @{ Name = $Name; } }

            Get-LabVMSnapshot -Name $testVMNames -SnapshotName $testSnapshotName 3>&1;

            Assert-MockCalled Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -Exactly $testVMNames.Count -Scope It;
        }

        It 'Warns when snapshot name cannot be found' {
            $testVMName = 'TestVM1';
            $testSnapshotName = 'Test snapshot';
            Mock Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -MockWith { }

            { Get-LabVMSnapshot -Name $testVMName -SnapshotName $testSnapshotName  -WarningAction Stop 3>&1 } | Should Throw;
        }

    } #end InModuleScope

} #end describe

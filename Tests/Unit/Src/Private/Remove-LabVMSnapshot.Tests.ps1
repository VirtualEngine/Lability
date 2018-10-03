#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVMSnapshot' {

    InModuleScope -ModuleName $moduleName {

        It 'Calls "Get-VMSnapshot" for each virtual machine specified' {
            $testVMNames = 'TestVM1','TestVM2';
            Mock Get-VMSnapshot -MockWith { }

            Remove-LabVMSnapshot -Name $testVMNames;

            Assert-MockCalled Get-VMSnapshot -Exactly $testVMNames.Count -Scope It;
        }

        It 'Calls "Remove-VMSnapshot" for each virtual machine snapshot' {
            $testVMName = 'TestVM';
            $testSnapshotName = 'Test snapshot';
            $fakeSnapshots = @(
                [PSCustomObject] @{ VMName = $testVMName; Name = "$testSnapshotName 1"; }
                [PSCustomObject] @{ VMName = $testVMName; Name = "$testSnapshotName 2"; }
            )
            Mock Get-VMSnapshot -ParameterFilter { $VMName -eq $testVMName } -MockWith { return $fakeSnapshots; }
            Mock Remove-VMSnapshot -ParameterFilter { $VMName -eq $testVMName } -MockWith { }

            Remove-LabVMSnapshot -Name $testVMName

            Assert-MockCalled Remove-VMSnapshot -ParameterFilter { $VMName -eq $testVMName } -Exactly $fakeSnapshots.Count -Scope It;
        }

    } #end InModuleScope

} #end describe

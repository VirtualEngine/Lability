#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;


Describe 'LabVMSnapshot' {

    InModuleScope $moduleName {

        Context 'Validates "RemoveLabVMSnapshot" method' {

            It 'Calls "Get-VMSnapshot" for each virtual machine specified' {
                $testVMNames = 'TestVM1','TestVM2';
                Mock Get-VMSnapshot -MockWith { }

                RemoveLabVMSnapshot -Name $testVMNames;
                
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

                RemoveLabVMSnapshot -Name $testVMName
                
                Assert-MockCalled Remove-VMSnapshot -ParameterFilter { $VMName -eq $testVMName } -Exactly $fakeSnapshots.Count -Scope It;
            }
        
        } #end context Validates "RemoveLabVMSnapshot" method
        
        Context 'Validates "NewLabVMSnapshot" method' {

            It 'Calls "Checkpoint-VM" for each virtual machine specified' {
                $testVMNames = 'TestVM1','TestVM2';
                $testSnapshotName = 'Test snapshot';
                Mock Checkpoint-VM -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

                NewLabVMSnapshot -Name $testVMNames -SnapshotName $testSnapshotName;
                
                Assert-MockCalled Checkpoint-VM -Exactly $testVMNames.Count -Scope It;
            }
        
        }  #end context Validates "NewLabVMSnapshot" method

        Context 'Validates "GetLabVMSnapshot" method' {

            It 'Calls "Get-VMSnapshot" for each virtual machine specified' {
                $testVMNames = 'TestVM1','TestVM2';
                $testSnapshotName = 'Test snapshot';
                Mock Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -MockWith { return @{ Name = $Name; } }

                GetLabVMSnapshot -Name $testVMNames -SnapshotName $testSnapshotName 3>&1;
                
                Assert-MockCalled Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -Exactly $testVMNames.Count -Scope It;
            }

            It 'Warns when snapshot name cannot be found' {
                $testVMName = 'TestVM1';
                $testSnapshotName = 'Test snapshot';
                Mock Get-VMSnapshot -ParameterFilter { $Name -eq $testSnapshotName } -MockWith { }

                { GetLabVMSnapshot -Name $testVMName -SnapshotName $testSnapshotName  -WarningAction Stop 3>&1 } | Should Throw;
            }
        
        }  #end context Validates "GetLabVMSnapshot" method

    } #end InModuleScope

} #end describe LabVMSnapshot

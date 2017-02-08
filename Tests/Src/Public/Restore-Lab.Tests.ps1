#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Restore-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Restore-VMSnapshot -MockWith { } #TODO: Cannot mock pipeline input to Restore-VMSnapshot?
        Mock GetLabVMSnapshot -MockWith { }

        It 'Restores specified snapshot when VMs are powered off' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                )
            }
            $testSnapshotName = 'Test Snapshot';
            $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
            Mock Get-VM -MockWith { return [PSCustomObject] @{ Name = $Name; State = 'Off'; } }

            Restore-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName;

            Assert-MockCalled GetLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -Scope It;
        }

        It 'Restores VM snapshot using display name' {
            $testVMName = 'VM1';
            $testEnvironmentPrefix = 'Test_';
            $testVMDisplayName = '{0}{1}' -f $testEnvironmentPrefix, $testVMName;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
                NonNodeData = @{
                    Lability = @{
                        EnvironmentPrefix = $testEnvironmentPrefix;
                    }
                }
            }
            $testSnapshotName = 'Test Snapshot';
            Mock Get-VM -MockWith { return [PSCustomObject] @{ State = 'Off' }; }

            Restore-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName;

            Assert-MockCalled GetLabVMSnapshot -ParameterFilter { $Name -eq $testVMDisplayName };
        }

        It 'Errors when there is a running VM' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                )
            }
            $testSnapshotName = 'Test Snapshot';
            $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
            $fakeRunningVM = [PSCustomObject] @{ State = 'Running' };
            Mock Get-VM -MockWith { return @($fakeRunningVM, $fakeOffVM, $fakeOffVM); }

            { Restore-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -ErrorAction Stop } | Should Throw;
        }

        It 'Restores specified snapshot when there are running VMs and -Force is specified' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                )
            }
            $testSnapshotName = 'Test Snapshot';
            $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
            $fakeRunningVM = [PSCustomObject] @{ State = 'Running' };
            Mock Get-VM -MockWith { return @($fakeRunningVM, $fakeOffVM, $fakeOffVM); }

            Restore-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -Force;

            Assert-MockCalled GetLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -Scope It;
        }

    } #end InModuleScope

} #end describe

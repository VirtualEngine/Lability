#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Checkpoint-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Get-VM -MockWith { }
        Mock NewLabVMSnapshot -MockWith { }

        It 'Snapshots VMs when powered off' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                Mock Get-VM -MockWith { return [PSCustomObject] @{ State = 'Off' }; }

                Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName;

                Assert-MockCalled NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName };
            }

            It 'Snapshots VM using display name' {
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

                Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName;

                Assert-MockCalled NewLabVMSnapshot -ParameterFilter { $Name -eq $testVMDisplayName };
            }

            It 'Errors when there is one running VM' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
                $fakeRunningVM = [PSCustomObject] @{ State = 'Running' };
                Mock Get-VM -MockWith { return @($fakeRunningVM, $fakeOffVM, $fakeOffVM); }

                { Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -ErrorAction Stop } | Should Throw;
            }

            It 'Errors when there are multiple running VMs' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
                $fakeRunningVM = [PSCustomObject] @{ State = 'Running' };
                Mock Get-VM -MockWith { return @($fakeRunningVM, $fakeOffVM, $fakeRunningVM); }

                { Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -ErrorAction Stop } | Should Throw;
            }

            It 'Snapshots VMs when there are running VMs and -Force is specified' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
                $fakeRunningVM = [PSCustomObject] @{ State = 'Running' };
                Mock Get-VM -MockWith { return @($fakeRunningVM, $fakeOffVM, $fakeOffVM); }

                Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -Force;

                Assert-MockCalled NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName };
            }

    } #end InModuleScope

} #end describe

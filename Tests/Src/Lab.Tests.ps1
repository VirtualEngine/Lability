#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Lab' {

    InModuleScope $moduleName {
        
        Context 'Validates "Start-Lab" method' {

            It 'Starts all VMs' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                Mock Start-VM -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Start-Lab -ConfigurationData $configurationData;

                
                Assert-MockCalled Start-VM -Exactly ($configurationData.AllNodes).Count -Scope It;
            }
            
            It 'Starts VM using display name' {
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
                Mock Start-VM -ParameterFilter { $Name -eq $testVMDisplayName }  -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Start-Lab -ConfigurationData $configurationData;
                
                Assert-MockCalled Start-VM -ParameterFilter { $Name -eq $testVMDisplayName } -Scope It;
            }

            It 'Starts VMs in boot order' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; BootOrder = 2; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; BootOrder = 1; } # Defaults to 99
                    )
                }
                Mock Start-VM -MockWith { Write-Output $Name; }
                Mock Start-Sleep -MockWith { }

                $actualStartOrder = Start-Lab -ConfigurationData $configurationData;

                $actualStartOrder[0] | Should Be 'VM3';
                $actualStartOrder[1] | Should Be 'VM1';
                $actualStartOrder[2] | Should Be 'VM2';
            }

            It 'Does not call "Start-Sleep" if a zero boot delay is specified' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM3'; BootDelay = 0; }   # Defaults to a delay of 5 seconds
                    )
                }
                Mock Start-VM -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Start-Lab -ConfigurationData $configurationData;
                
                Assert-MockCalled Start-Sleep -Exactly ($configurationData.AllNodes | Where { $_.BootDelay -ne $null -and $_.BootDelay -gt 0 }).Count -Scope It;
            }
           
        } #end context Validates "Start-Lab" method

        Context 'Validates "Stop-Lab" method' {

            It 'Stops all VMs' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                Mock Stop-VM -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Stop-Lab -ConfigurationData $configurationData;
                
                Assert-MockCalled Stop-VM -Exactly ($configurationData.AllNodes).Count -Scope It;
            }

            It 'Stops VM using display name' {
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
                Mock Stop-VM -ParameterFilter { $Name -eq $testVMDisplayName }  -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Stop-Lab -ConfigurationData $configurationData;
                
                Assert-MockCalled Stop-VM -ParameterFilter { $Name -eq $testVMDisplayName } -Scope It;
            }
            
            It 'Stops VMs in boot order' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; BootOrder = 2; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; BootOrder = 1; } # Defaults to 99
                    )
                }
                Mock Stop-VM -MockWith { Write-Output $Name; }
                Mock Start-Sleep -MockWith { }

                $actualStopOrder = Stop-Lab -ConfigurationData $configurationData;

                $actualStopOrder[0] | Should Be 'VM2';
                $actualStopOrder[1] | Should Be 'VM1';
                $actualStopOrder[2] | Should Be 'VM3';
            }

            It 'Does not call "Start-Sleep" if a zero boot delay is specified' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM3'; BootDelay = 0; }   # Defaults to a delay of 5 seconds
                    )
                }
                Mock Stop-VM -MockWith { }
                Mock Start-Sleep -MockWith { }
                
                Stop-Lab -ConfigurationData $configurationData;
                
                Assert-MockCalled Start-Sleep -Exactly ($configurationData.AllNodes | Where { $_.BootDelay -ne $null -and $_.BootDelay -gt 0 }).Count -Scope It;
            }
           
        } #end context Validates "Stop-Lab" method

        Context 'Validates "Reset-Lab" method' {

            It 'Calls "Restore-Lab" with -Force switch' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                Mock Restore-Lab -ParameterFilter { $Force -eq $true } -MockWith { }

                Reset-Lab -ConfigurationData $configurationData;

                Assert-MockCalled Restore-Lab -ParameterFilter { $Force -eq $true } -Scope It;
            }
            
        } #end context Validates "Reset-Lab" method

        Context 'Validates "Checkpoint-Lab" method' {

            It 'Snapshots VMs when powered off' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                Mock Get-VM -MockWith { return [PSCustomObject] @{ State = 'Off' }; }
                Mock NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

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
                Mock NewLabVMSnapshot -ParameterFilter { $Name -eq $testVMDisplayName } -MockWith { }

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
                Mock NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

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
                Mock NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

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
                Mock NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

                Checkpoint-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -Force;

                Assert-MockCalled NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName };
            }

        } #end context Validates "Checkpoint-Lab" method

        Context 'Validates "Restore-Lab" method' {

            It 'Restores specified snapshot when VMs are powered off' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; }, @{ NodeName = 'VM3'; }
                    )
                }
                $testSnapshotName = 'Test Snapshot';
                $fakeOffVM = [PSCustomObject] @{ State = 'Off' };
                Mock Get-VM -MockWith { return [PSCustomObject] @{ Name = $Name; State = 'Off'; } }
                Mock Restore-VMSnapshot -MockWith { } #TODO: Cannot mock pipeline input to Restore-VMSnapshot?
                Mock GetLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }
                
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
                Mock Restore-VMSnapshot -MockWith { } #TODO: Cannot mock pipeline input to Restore-VMSnapshot?
                Mock GetLabVMSnapshot -ParameterFilter { $Name -eq $testVMDisplayName } -MockWith { }
                
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
                Mock NewLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

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
                Mock GetLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -MockWith { }

                Restore-Lab -ConfigurationData $configurationData -SnapshotName $testSnapshotName -Force;

                Assert-MockCalled GetLabVMSnapshot -ParameterFilter { $SnapshotName -eq $testSnapshotName } -Scope It;
            }
        
        } #end context Validates "Restore-Lab" method

    } #end InModuleScope

} #end describe Lab

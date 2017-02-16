#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Stop-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Stop-VM -MockWith { }
        Mock Start-Sleep -MockWith { }

        It 'Stops all VMs with matching boot order' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; },
                    @{ NodeName = 'VM2'; },
                    @{ NodeName = 'VM3'; }
                )
            }

            Stop-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Stop-VM -Exactly 1 -Scope It;
        }

        It 'Stops all VMs with differing boot orders individually' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; BootOrder = 1; },
                    @{ NodeName = 'VM2'; BootOrder = 2; },
                    @{ NodeName = 'VM3'; BootOrder = 3; }
                )
            }

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

            $actualStopOrder = Stop-Lab -ConfigurationData $configurationData;

            $actualStopOrder[0] | Should Be 'VM2';
            $actualStopOrder[1] | Should Be 'VM1';
            $actualStopOrder[2] | Should Be 'VM3';
        }

        It 'Calls "Stop-VM" with "Force"' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }
                )
            }

            Stop-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Stop-VM -ParameterFilter { $Force -eq $true } -Scope It;
        }

        It 'Does not call "Start-Sleep" if a zero boot delay is specified' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM3'; BootDelay = 0; }   # Defaults to a delay of 5 seconds
                )
            }

            Stop-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Start-Sleep -Exactly ($configurationData.AllNodes | Where { $_.BootDelay -ne $null -and $_.BootDelay -gt 0 }).Count -Scope It;
        }

    } #end InModuleScope

} #end describe

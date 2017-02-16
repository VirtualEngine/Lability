#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Start-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Start-VM -MockWith { }
        Mock Start-Sleep -MockWith { }

        It 'Starts all VMs with matching boot order' {

            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; },
                    @{ NodeName = 'VM2'; },
                    @{ NodeName = 'VM3'; }
                )
            }

            Start-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Start-VM -Exactly 1 -Scope It;
        }

        It 'Starts all VMs with differing boot orders individually' {
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; BootOrder = 1; },
                    @{ NodeName = 'VM2'; BootOrder = 2; },
                    @{ NodeName = 'VM3'; BootOrder = 3; }
                )
            }

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

            Start-Lab -ConfigurationData $configurationData;

            Assert-MockCalled Start-Sleep -Exactly ($configurationData.AllNodes | Where { $_.BootDelay -ne $null -and $_.BootDelay -gt 0 }).Count -Scope It;
        }

    } #end InModuleScope

} #end describe

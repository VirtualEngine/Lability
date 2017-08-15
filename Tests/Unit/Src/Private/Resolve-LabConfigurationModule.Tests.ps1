#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabConfigurationModule' {

    InModuleScope $moduleName {

        $testConfigurationData = @{
            NonNodeData = @{
                Lability = @{
                    DscResource = @(
                        @{ Name = 'TestDscResource1'; }
                        @{ Name = 'TestDscResource2'; }
                    )
                    Module = @(
                        @{ Name = 'TestModule1'; }
                        @{ Name = 'TestModule2'; }
                        @{ Name = 'TestModule3'; }
                    )
                }
            }
        }

        It 'Returns all PowerShell modules if no "Name" is specified' {
            $resolveLabConfigurationModuleParams = @{
                ConfigurationData = $testConfigurationData;
                ModuleType = 'Module';
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.Module.Count;
        }

        It 'Returns all PowerShell modules if "*" is specified' {
            $resolveLabConfigurationModuleParams = @{
                ConfigurationData = $testConfigurationData;
                ModuleType = 'Module';
                Name  = '*';
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.Module.Count;
        }

        It 'Returns all DSC resources if no "Name" is specified' {
            $resolveLabConfigurationModuleParams = @{
                ConfigurationData = $testConfigurationData;
                ModuleType = 'DscResource';
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.DscResource.Count;
        }

        It 'Returns all DSC resources if "*" is specified' {
            $resolveLabConfigurationModuleParams = @{
                ConfigurationData = $testConfigurationData;
                ModuleType = 'DscResource';
                Name  = '*';
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testConfigurationData.NonNodeData.Lability.DscResource.Count;
        }

        It 'Returns matching PowerShell modules when "Name" is specified' {
            $testModules = 'TestModule2','TestModule1';
            $resolveLabConfigurationModuleParams = @{
                Name  = $testModules;
                ModuleType = 'Module';
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{
                            Module = @(
                                @{ Name = 'TestModule1'; }
                                @{ Name = 'TestModule2'; }
                                @{ Name = 'TestModule3'; }
                            )
                        }
                    }
                }
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testModules.Count;
        }

        It 'Returns matching DSC resources when "Name" is specified' {
            $testDscResources = 'TestDscResource3';
            $resolveLabConfigurationModuleParams = @{
                Name  = $testDscResources;
                ModuleType = 'DscResource';
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{
                            DscResource = @(
                                @{ Name = 'TestDscResource1'; }
                                @{ Name = 'TestDscResource2'; }
                                @{ Name = 'TestDscResource3'; }
                            )
                        }
                    }
                }
            }

            $result = Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams;

            $result.Count | Should Be $testDscResources.Count;
        }

        It 'Warns if a PowerShell module cannot be resolved' {
            $resolveLabConfigurationModuleParams = @{
                Name  = 'TestModule4';
                ModuleType = 'Module';
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{
                            DscResource = @(
                                @{ Name = 'TestModule1'; }
                                @{ Name = 'TestModule2'; }
                                @{ Name = 'TestModule3'; }
                            )
                        }
                    }
                }
            }

            { Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams -WarningAction Stop 3>&1 } | Should Throw;
        }

        It 'Warns if a DSC resource cannot be resolved' {
            $resolveLabConfigurationModuleParams = @{
                Name  = 'TestDscResource4';
                ModuleType = 'DscResource';
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{
                            DscResource = @(
                                @{ Name = 'TestDscResource1'; }
                                @{ Name = 'TestDscResource2'; }
                                @{ Name = 'TestDscResource3'; }
                            )
                        }
                    }
                }
            }

            { Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams -WarningAction Stop 3>&1 } | Should Throw;
        }

        It 'Throws if a PowerShell module cannot be resolved and "ThrowIfNotFound" is specified' {
            $resolveLabConfigurationModuleParams = @{
                Name  = 'TestModule4';
                ModuleType = 'Module';
                ThrowIfNotFound = $true;
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{ }
                    }
                }
            }

            { Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams } | Should Throw;
        }

        It 'Throws if a DSC resource cannot be resolved and "ThrowIfNotFound" is specified' {
            $resolveLabConfigurationModuleParams = @{
                Name  = 'TestDscResource';
                ModuleType = 'DscResource';
                ThrowIfNotFound = $true;
                ConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{ }
                    }
                }
            }

            { Resolve-LabConfigurationModule @resolveLabConfigurationModuleParams } | Should Throw;
        }

    } #end InModuleScope

} #end describe

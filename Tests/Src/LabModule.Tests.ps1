#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\LabModule' {

    InModuleScope $moduleName {

        Context 'Validates "ResolveLabModule" method' {

            $testNode = 'TestNode';

            It 'Returns "System.Collections.Hashtable" object type' {

                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{
                        AllNodes = @( @{ NodeName = $testNode; } )
                        NonNodeData = @{
                            Lability = @{
                                Module = @(
                                    @{ Name = 'TestModule1'; }
                                )
                            }
                        }
                    }
                }
                $result = ResolveLabModule @testParams -ModuleType Module -Verbose;

                $result -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Returns all PowerShell modules when not defined on the node' {

                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{
                        AllNodes = @( @{ NodeName = $testNode; } )
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
                $result = ResolveLabModule @testParams -ModuleType Module -Verbose;

                $result.Count | Should Be $testParams.ConfigurationData.NonNodeData.Lability.Module.Count;
            }

            It 'Returns all DSC resources when not defined on the node' {

                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{
                        AllNodes = @( @{ NodeName = $testNode; } )
                        NonNodeData = @{
                            Lability = @{
                                DscResource = @(
                                    @{ Name = 'TestDscResource1'; }
                                    @{ Name = 'TestDscResource2'; }
                                )
                            }
                        }
                    }
                }
                $result = ResolveLabModule @testParams -ModuleType DscResource -Verbose;

                $result.Count | Should Be $testParams.ConfigurationData.NonNodeData.Lability.DscResource.Count;
            }

            It 'Returns PowerShell modules only defined on the node' {

                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{
                        AllNodes = @( @{ NodeName = $testNode; Module = 'TestModule3','TestModule1' } )
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
                $result = ResolveLabModule @testParams -ModuleType Module -Verbose;

                $result.Count | Should Be $testParams.ConfigurationData.AllNodes[0].Module.Count;
            }

            It 'Returns DSC resource modules only defined on the node' {

                $testParams = @{
                    NodeName = $testNode;
                    ConfigurationData = @{
                        AllNodes = @( @{ NodeName = $testNode; DscResource = 'TestDscResource2' } )
                        NonNodeData = @{
                            Lability = @{
                                DscResource = @(
                                    @{ Name = 'TestDscResource1'; }
                                    @{ Name = 'TestDscResource2'; }
                                )
                            }
                        }
                    }
                }
                $result = ResolveLabModule @testParams -ModuleType DscResource -Verbose;

                $result.Count | Should Be $testParams.ConfigurationData.AllNodes[0].DscResource.Count;
            }

        } #end context Validates "New-ResolveLabModule" method

    } #end InModuleScope

} #end describe Src\LabModule

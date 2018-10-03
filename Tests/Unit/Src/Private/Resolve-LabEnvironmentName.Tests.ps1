#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabEnvironmentName' {

    InModuleScope $moduleName {

        It 'Should return a "System.String" object type' {
            $testName = 'Test';
            $configurationData = @{
                NonNodeData = @{
                    Lability = @{ }
                }
            }

            $result = Resolve-LabEnvironmentName -Name $testName -ConfigurationData $configurationData;

            $result -is [System.String] | Should Be $true;
        }

        It 'Should return name when no environment prefix/suffix is defined' {
            $testName = 'Test';
            $configurationData = @{
                NonNodeData = @{
                    Lability = @{ }
                }
            }

            $result = Resolve-LabEnvironmentName -Name $testName -ConfigurationData $configurationData;

            $result | Should Be $testName;
        }

        It 'Should return a prefixed name when environment prefix is defined' {
            $testName = 'Test';
            $testPrefix = 'Prefix';
            $configurationData = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentPrefix = $testPrefix;
                    }
                }
            }

            $result = Resolve-LabEnvironmentName -Name $testName -ConfigurationData $configurationData;

            $result | Should Be ('{0}{1}' -f $testPrefix, $testName);
        }

        It 'Should return a suffixed name when environment suffix is defined' {
            $testName = 'Test';
            $testSuffix = 'Suffix';
            $configurationData = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentSuffix = $testSuffix;
                    }
                }
            }

            $result = Resolve-LabEnvironmentName -Name $testName -ConfigurationData $configurationData;

            $result | Should Be ('{0}{1}' -f $testName, $testSuffix);
        }

        It 'Should return a prefixed/suffixed name when environment prefix and suffix is defined' {
            $testName = 'Test';
            $testPrefix = 'Prefix';
            $testSuffix = 'Suffix';
            $configurationData = @{
                NonNodeData = @{
                    Lability = @{
                        EnvironmentPrefix = $testPrefix;
                        EnvironmentSuffix = $testSuffix;
                    }
                }
            }

            $result = Resolve-LabEnvironmentName -Name $testName -ConfigurationData $configurationData;

            $result | Should Be ('{0}{1}{2}' -f $testPrefix, $testName, $testSuffix);
        }

    } #end InModuleScope

} #end describe

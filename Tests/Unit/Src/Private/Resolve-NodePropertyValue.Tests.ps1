#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-NodePropertyValue' {

    InModuleScope $moduleName {

        It 'Returns a "System.Collections.Hashtable" object type' {
            $testVMName = 'TestVM';
            $testVMProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*'; ProcessorCount = 8; }
                    @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $vmProperties -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Returns node-specific configuration data when present' {
            $testVMName = 'TestVM';
            $testVMProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*'; ProcessorCount = 8; }
                    @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
        }

        It 'Returns node-specific configuration data when present and "NoEnumerateWildcardNode" is specified' {
            $testVMName = 'TestVM';
            $testVMProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*'; ProcessorCount = 8; }
                    @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName -NoEnumerateWildcardNode;

            $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
        }

        It 'Returns wildcard node when node-specific data is not defined' {
            $testVMName = 'TestVM';
            $testAllNodesProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*'; ProcessorCount = $testAllNodesProcessorCount; }
                    @{ NodeName = $testVMName; }
                )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $vmProperties.ProcessorCount | Should Be $testAllNodesProcessorCount;
        }

        It 'Returns default when "NoEnumerateWildcardNode" is specified and node-specific data is not defined' {
            $testVMName = 'TestVM';
            $testAllNodesProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*'; ProcessorCount = $testAllNodesProcessorCount; }
                    @{ NodeName = $testVMName; }
                )
            }

            $hostDefaultProperties = Get-LabVMDefault;
            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName -NoEnumerateWildcardNode;

            $vmProperties.ProcessorCount | Should Be $hostDefaultProperties.ProcessorCount;
        }

        It 'Returns default if wildcard and node-specific data is not present' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            $hostDefaultProperties = Get-LabVMDefault;
            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $vmProperties.ProcessorCount | Should Be $hostDefaultProperties.ProcessorCount;
        }

        It "Returns ""$($labDefaults.moduleName)_"" specific properties over generic properties" {
            $testVMName = 'TestVM';
            $testVMProcessorCount = 42;
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; ProcessorCount = 99; "$($labDefaults.ModuleName)_ProcessorCount" = $testVMProcessorCount; }
                )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
        }

        It 'Adds "EnvironmentPrefix" to "NodeDisplayName" when defined' {
            $testVMName = 'TestVM';
            $testPrefix = 'TestPrefix';
            $configurationData = @{
                AllNodes = @( @{ NodeName = $testVMName; } )
                NonNodeData = @{ Lability = @{ EnvironmentPrefix = $testPrefix; } }
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $expected = '{0}{1}' -f $testPrefix, $testVMName;
            $vmProperties.NodeDisplayName | Should Be $expected;
        }

        It 'Adds "EnvironmentSuffix" to "NodeDisplayName" when defined' {
            $testVMName = 'TestVM';
            $testSuffix = 'TestSuffix';
            $configurationData = @{
                AllNodes = @( @{ NodeName = $testVMName; } )
                NonNodeData = @{ Lability = @{ EnvironmentSuffix = $testSuffix; } }
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testVMName;

            $expected = '{0}{1}' -f $testVMName, $testSuffix;
            $vmProperties.NodeDisplayName | Should Be $expected;
        }

        It 'Returns NetBIOS display name when FQDN defined and UseNetBIOSName = "true" (#335)' {
            $testVMName = 'TestVM';
            $testVMDomainName = 'lab.local';
            $testNodeName = "$testVMName.$testVMDomainName";
            $configurationData = @{
                AllNodes = @( @{ NodeName = $testNodeName; UseNetBIOSName = $true; } )
            }

            $vmProperties = Resolve-NodePropertyValue -ConfigurationData $configurationData -NodeName $testNodeName;

            $vmProperties.NodeDisplayName | Should Be $testVMName;
        }

    } #end InModuleScope

} #end describe

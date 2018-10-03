#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabSwitch' {

    InModuleScope $moduleName {

        Mock Get-VMSwitch { }

        It 'Returns a "System.Collections.Hashtable" object type' {
            $testSwitchName = 'Test Switch';
            $defaultSwitchName = 'DefaultInternalSwitch';
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { }

            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @( ) } } }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }

            $labSwitch = Resolve-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName -WarningAction SilentlyContinue;

            $labSwitch -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Returns specified network switch from configuration data if defined' {
            $testSwitchName = 'Test Switch';
            $testSwitchType = 'Private';
            $defaultSwitchName = 'DefaultInternalSwitch';

            $fakeExistingSwitch = [PSCustomObject] @{
                Name = $testSwitchName;
                SwitchType = 'External';
                AllowManagementOS = $true;
                NetAdapterInterfaceDescription = 'Ethernet Adapter #1';
                IsExisting = $true;
            }

            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @(
                            @{ Name = $testSwitchName; Type = $testSwitchType; }
                        ) } } }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }

            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-NetAdapter { return @{ Name = 'Ethernet Adapter #1';} }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeExistingSwitch; }

            $labSwitch = Resolve-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName -WarningAction SilentlyContinue;;

            $labSwitch.Name | Should Be $testSwitchName;
            $labSwitch.Type | Should Be $testSwitchType;
            $labSwitch.IsExisting | Should BeNullOrEmpty;
        }


        It 'Returns existing "External" switch if "Name" cannot be resolved' {
            $testSwitchName = 'Test Switch';
            $testSwitchType = 'External';

            $fakeExistingSwitch = [PSCustomObject] @{
                Name = $testSwitchName;
                SwitchType = $testSwitchType;
                AllowManagementOS = $true;
                NetAdapterInterfaceDescription = 'Ethernet Adapter #1';
                IsExisting = $true;
            }
            $configurationData = @{ }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = 'DefaultInternalSwitch'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeExistingSwitch; }
            Mock Get-NetAdapter { return @{ Name = 'Ethernet Adapter #1';} }

            $labSwitch = Resolve-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName -WarningAction SilentlyContinue;

            $labSwitch.Name | Should Be $testSwitchName;
            $labSwitch.Type | Should Be $testSwitchType;
            $labSwitch.IsExisting | Should Be $true;
        }

        It 'Returns a default "Internal" switch if the switch cannot be resolved' {
            $testSwitchName = 'TestSwitch';
            $defaultSwitchName = 'DefaultInternalSwitch';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @( ) } } }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { }

            $labSwitch = Resolve-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName -WarningAction SilentlyContinue;;

            $labSwitch.Name | Should Be $testSwitchName;
            $labSwitch.Type | Should Be 'Internal';
            $labSwitch.IsExisting | Should BeNullOrEmpty;
        }

        It 'Does not return a prefixed switch name when DisableSwitchEnvironmentName is enabled' {
            $testSwitchName = 'Test Switch';
            $testPrefix = 'Prefix';
            $defaultSwitchName = 'DefaultInternalSwitch';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        EnvironmentPrefix = $testPrefix;
                     }
                }
            }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }
            $defaultHostConfigurationData = [PSCustomObject] @{ DisableSwitchEnvironmentName = $true; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $defaultHostConfigurationData; }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { }

            $resolveLabSwitchParams = @{
                ConfigurationData = $configurationData;
                Name = $testSwitchName;
                WarningAction = 'SilentlyContinue';
            }
            $labSwitch = Resolve-LabSwitch @resolveLabSwitchParams;

            $labSwitch.Name | Should Be $testSwitchName;
        }

        It 'Returns a prefixed switch name when an environment prefix is defined' {
            $testSwitchName = 'Test Switch';
            $testPrefix = 'Prefix';
            $defaultSwitchName = 'DefaultInternalSwitch';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        EnvironmentPrefix = $testPrefix;
                     }
                }
            }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }
            $defaultHostConfigurationData = [PSCustomObject] @{ DisableSwitchEnvironmentName = $false; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $defaultHostConfigurationData; }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { }

            $resolveLabSwitchParams = @{
                ConfigurationData = $configurationData;
                Name = $testSwitchName;
                WarningAction = 'SilentlyContinue';
            }
            $labSwitch = Resolve-LabSwitch @resolveLabSwitchParams;

            $labSwitch.Name | Should Be ('{0}{1}' -f $testPrefix, $testSwitchName);
        }

        It 'Returns a suffixed switch name when an environment suffix is defined' {
            $testSwitchName = 'Test Switch';
            $testSuffix = 'Suffix';
            $defaultSwitchName = 'DefaultInternalSwitch';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        EnvironmentSuffix = $testSuffix;
                     }
                }
            }
            $defaultVMConfigurationData = [PSCustomObject] @{ SwitchName = $defaultSwitchName; }
            $defaultHostConfigurationData = [PSCustomObject] @{ DisableSwitchEnvironmentName = $false; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $defaultVMConfigurationData; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $defaultHostConfigurationData; }
            Mock Get-VMSwitch -ParameterFilter { $Name -eq $testSwitchName } { }

            $resolveLabSwitchParams = @{
                ConfigurationData = $configurationData;
                Name = $testSwitchName;
                WarningAction = 'SilentlyContinue';
            }
            $labSwitch = Resolve-LabSwitch @resolveLabSwitchParams;

            $labSwitch.Name | Should Be ('{0}{1}' -f $testSwitchName,$testSuffix);
        }

    } #end InModuleScope

} #end describe

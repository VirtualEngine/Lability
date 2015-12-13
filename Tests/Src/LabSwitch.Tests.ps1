#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabSwitch' {

    InModuleScope $moduleName {

        Context 'Validates "NewLabSwitch" method' {
            
            It 'Returns a "System.Collections.Hashtable" object type' {
                $testSwitchName = 'TestSwitch';
                $newSwitchParams = @{
                    Name = $testSwitchName;
                    Type = 'Internal';
                }
                $labSwitch = NewLabSwitch @newSwitchParams;
                $labSwitch -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Throws when switch type is "External" and "NetAdapterName" is not specified' {
                $testSwitchName = 'TestSwitch';
                $newSwitchParams = @{
                    Name = $testSwitchName;
                    Type = 'External';
                }
                
                { NewLabSwitch @newSwitchParams } | Should Throw;
            }

            It 'Removes "NetAdapterName" if switch type is not "External"' {
                $testSwitchName = 'TestSwitch';
                $newSwitchParams = @{
                    Name = $testSwitchName;
                    Type = 'Internal';
                }
                
                $labSwitch = NewLabSwitch @newSwitchParams;
                
                $labSwitch.NetAdapaterName | Should BeNullOrEmpty;
            }

            It 'Removes "AllowManagementOS" if switch type is not "External"' {
                $testSwitchName = 'TestSwitch';
                $newSwitchParams = @{
                    Name = $testSwitchName;
                    Type = 'Internal';
                }
                
                $labSwitch = NewLabSwitch @newSwitchParams;
                
                $labSwitch.AllowManagementOS | Should BeNullOrEmpty;
            }

        } #end context Validates "NewLabSwitch" method

        Context 'Validates "ResolveLabSwitch" method' {
            
            It 'Returns a "System.Collections.Hashtable" object type' {
                $testSwitchName = 'Test Switch';
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                $fakeConfigurationData = [PSCustomObject] @{ SwitchName = 'DefaultInternalSwitch'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $fakeConfigurationData; }

                $labSwitch = ResolveLabSwitch -ConfigurationData $configurationData -Name $testSwitchName;
                
                $labSwitch -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Returns specified network switch from configuration data if defined' {
                $testSwitchName = 'Test Switch';
                $testSwitchType = 'Private';
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @(
                                @{ Name = $testSwitchName; Type = $testSwitchType; }
                            ) } } }
                $fakeConfigurationData = [PSCustomObject] @{ SwitchName = 'DefaultInternalSwitch'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $fakeConfigurationData; }

                $labSwitch = ResolveLabSwitch -ConfigurationData $configurationData -Name $testSwitchName;
                
                $labSwitch.Name | Should Be $testSwitchName;
                $labSwitch.Type | Should Be $testSwitchType;
            }

            It 'Returns the default "Internal" switch if "Name" parameter cannot be resolved' {
                $testSwitchName = 'Test Switch';
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                $fakeConfigurationData = [PSCustomObject] @{ SwitchName = 'DefaultInternalSwitch'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'VM' } -MockWith { return $fakeConfigurationData; }

                $labSwitch = ResolveLabSwitch -ConfigurationData $configurationData -Name $testSwitchName;
                
                $labSwitch.Type | Should Be 'Internal';
            }
        } #end context Validates "ResolveLabSwitch" method

        Context 'Validates "TestLabSwitch" method' {

            It 'Passes when network switch is found' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $true; }
                
                TestLabSwitch -ConfigurationData $configurationData -Name 'ExistingSwitch' | Should Be $true;
            }

            It 'Fails when network switch is not found' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $false; }
                
                TestLabSwitch -ConfigurationData $configurationData -Name 'NonExistentSwitch' | Should Be $false;
            }

        } #end context Validates "TestLabSwitch" method

        Context 'Validates "SetLabSwitch" method' {

            It 'Calls "InvokeDscResource"' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $false; }

                SetLabSwitch -ConfigurationData $configurationData -Name 'Test Switch';

                Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -Scope It;
            }
        } #end context Validates "SetLabSwitch" method

        Context 'Validates "RemoveLabSwitch" method' {

            It 'Calls "InvokeDscResource" with "Ensure" = "Absent"' { 
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Network = @( ) } } }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -MockWith { return $false; }

                RemoveLabSwitch -ConfigurationData $configurationData -Name 'Test Switch';

                Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It;
            } #end context Validates "RemoveLabSwitch" method
        
        } #end context Validates "RemoveLabSwitch" method

    } #end InModuleScope

} #end describe LabSwitch

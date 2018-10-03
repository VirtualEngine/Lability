#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabSwitch' {

    InModuleScope $moduleName {

        It 'Passes when network switch is found' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @( ) } } }
            Mock Import-LabDscResource -MockWith { }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $true; }

            Test-LabSwitch -ConfigurationData $configurationData -Name 'ExistingSwitch' | Should Be $true;
        }

        It 'Passes when an existing switch is found' {
            $testSwitchName = 'Existing Virtual Switch';
            $fakeExistingSwitch = [PSCustomObject] @{
                Name = $testSwitchName;
                SwitchType = 'Private';
                IsExisting = $true;
            }
            $configurationData = @{ }
            Mock Resolve-LabSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeExistingSwitch; }

            Test-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName | Should Be $true;
        }

        It 'Fails when network switch is not found' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @( ) } } }
            Mock Get-VMSwitch { }
            Mock Import-LabDscResource -MockWith { }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $false; }

            Test-LabSwitch -ConfigurationData $configurationData -Name 'NonExistentSwitch' | Should Be $false;
        }

    } #end InModuleScope

} #end describe

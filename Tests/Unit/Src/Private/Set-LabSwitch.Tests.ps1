#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabSwitch' {

    InModuleScope $moduleName {

        It 'Calls "InvokeDscResource"' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Network = @( ) } } }
            Mock Get-VMSwitch { }
            Mock ImportDscResource -MockWith { }
            Mock InvokeDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -MockWith { return $false; }

            Set-LabSwitch -ConfigurationData $configurationData -Name 'Test Switch';

            Assert-MockCalled InvokeDscResource -ParameterFilter { $ResourceName -eq 'VMSwitch' } -Scope It;
        }

        It 'Does not call "InvokeDscResource" for an existing switch' {
            $testSwitchName = 'Existing Virtual Switch';
            $fakeExistingSwitch = [PSCustomObject] @{
                Name = $testSwitchName;
                SwitchType = 'Private';
                IsExisting = $true;
            }
            $configurationData = @{ }
            Mock Resolve-LabSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeExistingSwitch; }
            Mock InvokeDscResource { }

            Set-LabSwitch -ConfigurationData $configurationData -Name $testSwitchName;

            Assert-MockCalled InvokeDscResource -Exactly 0 -Scope It;
        }

    } #end InModuleScope

} #end describe

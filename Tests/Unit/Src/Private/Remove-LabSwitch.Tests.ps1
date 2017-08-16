#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabSwitch' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock Invoke-LabDscResource { }

        It 'Calls "Invoke-LabDscResource" with "Ensure" = "Absent" when switch exists' {
            $testSwitchName = 'Existing Virtual Switch';
            $fakeExistingSwitch = @{
                Name = $testSwitchName;
                SwitchType = 'Private';
                IsExisting = $true;
            }
            Mock Resolve-LabSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeExistingSwitch; }

            Remove-LabSwitch -ConfigurationData @{ } -Name $testSwitchName;

            Assert-MockCalled Invoke-LabDscResource -ParameterFilter { $Parameters['Ensure'] -eq 'Absent' } -Scope It;
        }

        It 'Does not call "Invoke-LabDscResource" for a non-existent switch' {
            $testSwitchName = 'Non-existent Virtual Switch';
            $fakeNonexistentSwitch = @{
                Name = $testSwitchName;
                SwitchType = 'Private';
            }
            Mock Resolve-LabSwitch -ParameterFilter { $Name -eq $testSwitchName } { return $fakeNonexistentSwitch}

            Remove-LabSwitch -ConfigurationData @{ } -Name $testSwitchName;

            Assert-MockCalled Invoke-LabDscResource -Exactly 0 -Scope It;
        }

    } #end InModuleScope

} #end describe
